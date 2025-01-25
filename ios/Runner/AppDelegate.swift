import UIKit
import Flutter
import CoreBluetooth
import QCBandSDK

@main
@objc class AppDelegate: FlutterAppDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var methodChannel: FlutterMethodChannel!
    private var scanEventChannel: FlutterEventChannel!
    private var connectionEventChannel: FlutterEventChannel!
    private var scanEventSink: FlutterEventSink?
    private var connectionEventSink: FlutterEventSink?
    private var connectedPeripheral: CBPeripheral?
    private let kLastConnectedDeviceKey = "LastConnectedDeviceKey"
    private var discoveredDevices: [[String: Any]] = []
    private var isPeripheralAdded: Bool = false
    private var deviceRSSI: [String: NSNumber] = [:]
    private var isInitialStateChecked = false
    private var isEventChannelSetup = false
    private let CONNECTION_TIMEOUT: TimeInterval = 10.0
    private var connectionTimer: Timer?
    private var keepAliveTimer: Timer?
    
    private var lastConnectedDeviceId: String? {
        get {
            return UserDefaults.standard.string(forKey: kLastConnectedDeviceKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: kLastConnectedDeviceKey)
            } else {
                UserDefaults.standard.removeObject(forKey: kLastConnectedDeviceKey)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        
        // Initialize CBCentralManager immediately to trigger permission prompt
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        // Setup Method Channel
        methodChannel = FlutterMethodChannel(
            name: "bluetooth_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        // Setup Event Channels
        scanEventChannel = FlutterEventChannel(
            name: "bluetooth_scan_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        connectionEventChannel = FlutterEventChannel(
            name: "bluetooth_connection_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        setupMethodChannel()
        setupEventChannels()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupMethodChannel() {
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "checkPermissions":
                self.handleCheckPermissions(result: result)
            case "requestPermissions":
                self.handleRequestPermissions(result: result)
            case "openSettings":
                self.handleOpenSettings(result: result)
            case "isBluetoothEnabled":
                self.handleIsBluetoothEnabled(result: result)
            case "enableBluetooth":
                self.handleEnableBluetooth(result: result)
            case "startScan":
                self.handleStartScan(result: result)
            case "stopScan":
                self.handleStopScan(result: result)
            case "connectToDevice":
                self.handleConnectToDevice(call: call, result: result)
            case "disconnectDevice":
                self.handleDisconnectDevice(result: result)
            case "getHeartRateHistory":
                self.handleGetHeartRateData(call: call, result: result)
         
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func setupEventChannels() {
        // Scan Event Channel
        scanEventChannel.setStreamHandler(ScanStreamHandler(sink: { [weak self] sink in
            self?.scanEventSink = sink
        }))
        
        // Connection Event Channel
        connectionEventChannel.setStreamHandler(ConnectionStreamHandler(sink: { [weak self] sink in
            self?.connectionEventSink = sink
            self?.isEventChannelSetup = true
            // Check initial connection state after event channel is ready
            self?.checkInitialConnectionState()
        }))
    }
    
    private func checkInitialConnectionState() {
        guard isEventChannelSetup, 
              centralManager.state == .poweredOn else { return }
        
        print("Checking initial connection state") // Debug log
        
        // Get all connected peripherals
        let connectedPeripherals = centralManager.retrievePeripherals(withIdentifiers: [])
        print("Found \(connectedPeripherals.count) connected peripherals") // Debug log
        
        // Check if we already have a connected peripheral
        if let existingPeripheral = connectedPeripheral, existingPeripheral.state == .connected {
            print("Using existing connected peripheral: \(existingPeripheral.name ?? "Unknown")") // Debug log
            sendConnectionState(peripheral: existingPeripheral, isConnected: true)
        }
        // If no active connection, check retrieved peripherals
        else if let peripheral = connectedPeripherals.first {
            print("Found previously connected peripheral: \(peripheral.name ?? "Unknown")") // Debug log
            connectedPeripheral = peripheral
            peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
        // Try to reconnect to last known device
        else if let deviceId = lastConnectedDeviceId {
            print("Attempting to reconnect to last known device ID: \(deviceId)") // Debug log
            
            guard let uuid = UUID(uuidString: deviceId),
                  let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first else {
                print("Failed to find peripheral with ID: \(deviceId)") // Debug log
                return
            }
            
            print("Found last known peripheral, attempting connection: \(peripheral.name ?? "Unknown")") // Debug log
            connectedPeripheral = peripheral
            peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    // MARK: - Method Channel Handlers
    
    private func handleCheckPermissions(result: @escaping FlutterResult) {
        if #available(iOS 13.1, *) {
            switch CBCentralManager.authorization {
            case .allowedAlways:
                result(true)
            case .denied, .restricted:
                result(false)
            case .notDetermined:
                // Force initialization of CBCentralManager to trigger the permission prompt
                if centralManager == nil {
                    centralManager = CBCentralManager(delegate: self, queue: nil)
                }
                // Return false to indicate permission hasn't been granted yet
                result(false)
            @unknown default:
                result(false)
            }
        } else {
            result(true)
        }
    }
    
    private func handleRequestPermissions(result: @escaping FlutterResult) {
        if #available(iOS 13.1, *) {
            // Explicitly initialize CBCentralManager to trigger the permission prompt
            if centralManager == nil {
                centralManager = CBCentralManager(delegate: self, queue: nil)
            }
            
            // Wait briefly to allow the permission prompt to appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleCheckPermissions(result: result)
            }
        } else {
            result(true)
        }
    }
    
    private func handleOpenSettings(result: @escaping FlutterResult) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:]) { _ in
                result(nil)
            }
        } else {
            result(
                FlutterError(
                    code: "SETTINGS_UNAVAILABLE",
                    message: "Cannot open settings",
                    details: nil
                )
            )
        }
    }
    
    private func handleIsBluetoothEnabled(result: @escaping FlutterResult) {
        result(centralManager.state == .poweredOn)
    }
    
    private func handleEnableBluetooth(result: @escaping FlutterResult) {
        // Cannot programmatically enable Bluetooth on iOS
        // Direct user to Settings instead
        handleOpenSettings(result: result)
    }
    
    private func handleStartScan(result: @escaping FlutterResult) {
        guard centralManager.state == .poweredOn else {
            result(
                FlutterError(
                    code: "BLUETOOTH_OFF",
                    message: "Bluetooth is not powered on",
                    details: nil
                )
            )
            return
        }
        
        // Clear the discovered devices list when starting a new scan
        discoveredDevices.removeAll()
        
        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
        result(nil)
    }
    
    private func handleStopScan(result: @escaping FlutterResult) {
        centralManager.stopScan()
        result(nil)
    }
    
    private func handleConnectToDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let deviceId = args["deviceId"] as? String,
              let uuid = UUID(uuidString: deviceId) else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Invalid device ID",
                details: nil
            ))
            return
        }
        
        lastConnectedDeviceId = deviceId
        print("Storing last connected device ID: \(deviceId)")
        
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first else {
            result(FlutterError(
                code: "DEVICE_NOT_FOUND",
                message: "Device not found",
                details: nil
            ))
            return
        }

        // Clean up any existing connection
        if let existingPeripheral = connectedPeripheral {
            QCSDKManager.shareInstance().remove(existingPeripheral)
            centralManager.cancelPeripheralConnection(existingPeripheral)
        }

        // Reset state
        isPeripheralAdded = false
        
        // Start connection timeout timer
        startConnectionTimer()
        
        connectedPeripheral = peripheral
        peripheral.delegate = self
        
        // Set connection options
        let options: [String: Any] = [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
            CBConnectPeripheralOptionNotifyOnNotificationKey: true,
            CBConnectPeripheralOptionStartDelayKey: 1
        ]
        
        // Add a small delay before connecting to ensure cleanup is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            if #available(iOS 13.0, *) {
                self.centralManager.connect(peripheral, options: options)
            } else {
                self.centralManager.connect(peripheral, options: nil)
            }
            
            result(nil)
        }
    }
    
    private func startConnectionTimer() {
        // Cancel any existing timer
        connectionTimer?.invalidate()
        
        // Start new timer
        connectionTimer = Timer.scheduledTimer(withTimeInterval: CONNECTION_TIMEOUT, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if let peripheral = self.connectedPeripheral, peripheral.state != .connected {
                print("Connection timeout - attempting to reconnect...")
                self.centralManager.cancelPeripheralConnection(peripheral)
                self.centralManager.connect(peripheral, options: nil)
            }
        }
    }
    
    private func startKeepAliveTimer() {
        // Cancel any existing timer
        keepAliveTimer?.invalidate()
        
        // Start new timer to read RSSI periodically
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let peripheral = self.connectedPeripheral,
                  peripheral.state == .connected else {
                return
            }
            
            // Read RSSI to keep connection alive
            peripheral.readRSSI()
        }
    }
    
    private func handleDisconnectDevice(result: @escaping FlutterResult) {
        // Clear stored device ID when explicitly disconnecting
        lastConnectedDeviceId = nil
        isPeripheralAdded = false
        
        // Stop all timers
        connectionTimer?.invalidate()
        connectionTimer = nil
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
        
        print("Clearing last connected device ID")
        
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        }
        result(nil)
    }
    
    private func handleGetHeartRateData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("🔍 handleGetHeartRateData called")
        
        // Add check for device readiness
        guard isDeviceReadyForRequests() else {
            print("❌ Device not ready for requests")
            result(FlutterError(
                code: "DEVICE_NOT_READY",
                message: "Device is not ready for requests",
                details: nil
            ))
            return
        }
        
        print("📝 Validating arguments...")
        guard let args = call.arguments as? [String: Any],
              let dayIndicesNS = args["dayIndices"] as? [Int] else {
            print("❌ Invalid arguments received")
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Invalid arguments",
                details: nil
            ))
            return
        }
        print("✅ Arguments validated successfully")
        
        print("🔌 Checking peripheral connection...")
        guard let peripheral = connectedPeripheral else {
            print("❌ No peripheral connected")
            result(FlutterError(
                code: "DEVICE_NOT_CONNECTED",
                message: "No device connected",
                details: nil
            ))
            return
        }
        print("✅ Peripheral connection confirmed")
        
        print("🔄 Converting day indices...")
        let dayIndices = dayIndicesNS.map { NSNumber(value: $0) }
        print("✅ Day indices converted: \(dayIndices)")
        
        print("⚡️ Ensuring peripheral is added...")
        ensurePeripheralAdded(peripheral: peripheral) {
            print("✅ Peripheral added successfully")
            
            let dispatchGroup = DispatchGroup()
            var heartRateData: [[String: Any]] = []
            var bloodOxygenData: [[String: Any]] = []
            var heartRateError: Error?
            
            // Get Heart Rate Data first
            dispatchGroup.enter()
            QCSDKCmdCreator.getSchedualHeartRateData(
                withDayIndexs: dayIndices,
                success: { models in
                    heartRateData = models.map { model -> [String: Any] in
                        return [
                            "date": model.date as Any? ?? "",
                            "heartRates": (model.heartRates ?? []) as [Any],
                            "secondInterval": model.secondInterval as Int,
                            "deviceId": model.deviceID as Any? ?? "",
                            "deviceType": model.deviceType as Any? ?? ""
                        ]
                    }
                    dispatchGroup.leave()
                },
                fail: { 
                    heartRateError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to read heart rate data"])
                    dispatchGroup.leave()
                }
            )
            
            // Wait for heart rate data to complete before starting blood oxygen requests
            dispatchGroup.notify(queue: .main) {
                // Process blood oxygen data sequentially with delays
                self.processBloodOxygenData(dayIndices: dayIndicesNS, currentIndex: 0) { finalBloodOxygenData in
                    // Combine and return the results
                    let combinedData: [String: Any] = [
                        "heartRateData": heartRateData,
                        "bloodOxygenData": finalBloodOxygenData
                    ]
                    
                    if let error = heartRateError {
                        result(FlutterError(
                            code: "DATA_READ_FAILED",
                            message: "Failed to read heart rate data: \(error.localizedDescription)",
                            details: nil
                        ))
                    } else {
                        result(combinedData)
                    }
                }
            }
        }
    }
    
    private func processBloodOxygenData(dayIndices: [Int], currentIndex: Int, accumulatedData: [[String: Any]] = [], completion: @escaping ([[String: Any]]) -> Void) {
        // Base case: if we've processed all indices, return the accumulated data
        if currentIndex >= dayIndices.count {
            completion(accumulatedData)
            return
        }
        
        let dayIndex = dayIndices[currentIndex]
        
        // Add a delay between requests
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            QCSDKCmdCreator.getBloodOxygenData(byDayIndex: dayIndex) { (models, error) in
                var newData = accumulatedData
                
                if let error = error {
                    print("Warning: Failed to get blood oxygen data for day \(dayIndex): \(error.localizedDescription)")
                } else if let models = models {
                    let oxygenData = (models as NSArray).map { item -> [String: Any] in
                        guard let model = item as? QCBloodOxygenModel else { return [:] }
                        return [
                            "date": model.date?.timeIntervalSince1970 ?? 0,
                            "bloodOxygenLevels": [model.soa2],
                            "secondInterval": 0,
                            "deviceId": model.device ?? "",
                            "deviceType": ""
                        ]
                    }
                    newData.append(contentsOf: oxygenData)
                }
                
                // Process next index recursively
                self.processBloodOxygenData(
                    dayIndices: dayIndices,
                    currentIndex: currentIndex + 1,
                    accumulatedData: newData,
                    completion: completion
                )
            }
        }
    }
    
    private func ensurePeripheralAdded(peripheral: CBPeripheral, completion: @escaping () -> Void) {
        // Only add peripheral if it hasn't been added yet
        if !isPeripheralAdded {
            QCSDKManager.shareInstance().add(peripheral) { _ in
                self.isPeripheralAdded = true
                completion()
            }
        } else {
            // If peripheral is already added, just call completion
            completion()
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on. Attempting to reconnect...")

            // Check if there's a previously connected device
            if let deviceId = lastConnectedDeviceId, 
               let uuid = UUID(uuidString: deviceId) {
                let peripherals = central.retrievePeripherals(withIdentifiers: [uuid])

                if let peripheral = peripherals.first {
                    print("Found previously connected device: \(peripheral.name ?? "Unknown"). Reconnecting...")

                    // Clean up the SDK state for the peripheral
                    QCSDKManager.shareInstance().remove(peripheral)

                    // Save the peripheral and connect
                    connectedPeripheral = peripheral
                    central.connect(peripheral, options: nil)
                } else {
                    print("No known devices found for reconnection.")
                }
            } else {
                print("No last connected device found.")
            }

        case .poweredOff:
            print("Bluetooth is powered off. Cleaning up state...")

            // Remove the peripheral and clean up the SDK state
            if let peripheral = connectedPeripheral {
                QCSDKManager.shareInstance().remove(peripheral)
                connectedPeripheral = nil
                isPeripheralAdded = false
            }

        default:
            print("Bluetooth state changed to: \(central.state.rawValue)")
        }
    }
    
    private func sendConnectionState(peripheral: CBPeripheral, isConnected: Bool) {
        print("Sending connection state - Connected: \(isConnected), Device: \(peripheral.name ?? "Unknown")") // Debug log
        
        let deviceInfo: [String: Any] = [
            "connected": isConnected,
            "state": isConnected ? "connected" : "disconnected",
            "device": [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": 0,
                "manufacturerData": ""
            ]
        ]
        connectionEventSink?(deviceInfo)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        // Only process devices that start with "R0"
        guard let name = peripheral.name,
              name.hasPrefix("R0") else {
            return
        }
        
        // Store RSSI for the device
        deviceRSSI[peripheral.identifier.uuidString] = RSSI
        
        let device: [String: Any] = [
            "id": peripheral.identifier.uuidString,
            "name": name,
            "rssi": RSSI.intValue,  // Use actual RSSI value
            "manufacturerData": advertisementData[CBAdvertisementDataManufacturerDataKey] as? String ?? ""
        ]
        
        // Check if device already exists in the list
        if let index = discoveredDevices.firstIndex(where: { ($0["id"] as? String) == peripheral.identifier.uuidString }) {
            // Update existing device
            discoveredDevices[index] = device
        } else {
            // Add new device
            discoveredDevices.append(device)
        }
        
        // Send the complete list of discovered devices
        scanEventSink?(discoveredDevices)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to device: \(peripheral.name ?? "Unknown")")
        
        // Cancel connection timer
        connectionTimer?.invalidate()
        connectionTimer = nil
        
        // Start keep-alive timer
        startKeepAliveTimer()
        
        // Set high priority for the connection
//       if #available(iOS 11.0, *) {
//        peripheral.setDesiredConnectionLatency(.connectionLatencyLow, for: peripheral)
//    }
//    
        
        // Add a delay before adding to SDK to ensure proper initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            QCSDKManager.shareInstance().add(peripheral) { _ in
                self.isPeripheralAdded = true
                
                // Add another small delay after SDK initialization
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.sendConnectionState(peripheral: peripheral, isConnected: true)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Device disconnected - Last known ID: \(lastConnectedDeviceId ?? "None")")
        if let error = error {
            print("Disconnect error: \(error.localizedDescription)")
        }
        
        // Stop keep-alive timer
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
        
        isPeripheralAdded = false
        
        // Attempt immediate reconnection if disconnection was unexpected
        if lastConnectedDeviceId != nil && error != nil {
            print("Unexpected disconnection - attempting immediate reconnection...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.centralManager.connect(peripheral, options: nil)
            }
            return
        }
        
        connectedPeripheral = nil
        
        let disconnectInfo: [String: Any] = [
            "connected": false,
            "state": "disconnected",
            "device": [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": 0,
                "manufacturerData": ""
            ]
        ]
        connectionEventSink?(disconnectInfo)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        isPeripheralAdded = false
        
        let failureInfo: [String: Any] = [
            "connected": false,
            "state": "failed",
            "device": [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": 0,
                "manufacturerData": ""
            ]
        ]
        connectionEventSink?(failureInfo)
    }
    
    func centralManager(_ central: CBCentralManager, willConnect peripheral: CBPeripheral) {
        let connectingInfo: [String: Any] = [
            "connected": false,
            "state": "connecting",
            "device": [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": 0,
                "manufacturerData": ""
            ]
        ]
        connectionEventSink?(connectingInfo)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateState state: CBPeripheralState) {
        print("Peripheral state updated: \(state.rawValue)") // Debug log
        let isConnected = state == .connected
        sendConnectionState(peripheral: peripheral, isConnected: isConnected)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
            return
        }
        
        deviceRSSI[peripheral.identifier.uuidString] = RSSI
        if peripheral.state == .connected {
            sendConnectionState(peripheral: peripheral, isConnected: true)
        }
        
        // Schedule next RSSI reading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if peripheral.state == .connected {
                peripheral.readRSSI()
            }
        }
    }
    
    // Add this helper method to check if device is ready for requests
    private func isDeviceReadyForRequests() -> Bool {
        guard let peripheral = connectedPeripheral,
              peripheral.state == .connected,
              isPeripheralAdded else {
            return false
        }
        return true
    }
}


// MARK: - Stream Handlers

class ScanStreamHandler: NSObject, FlutterStreamHandler {
    private var sinkCallback: ((FlutterEventSink?) -> Void)?
    
    init(sink callback: @escaping (FlutterEventSink?) -> Void) {
        sinkCallback = callback
        super.init()
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sinkCallback?(events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sinkCallback?(nil)
        return nil
    }
}

class ConnectionStreamHandler: NSObject, FlutterStreamHandler {
    private var sinkCallback: ((FlutterEventSink?) -> Void)?
    
    init(sink callback: @escaping (FlutterEventSink?) -> Void) {
        sinkCallback = callback
        super.init()
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sinkCallback?(events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sinkCallback?(nil)
        return nil
    }
}
