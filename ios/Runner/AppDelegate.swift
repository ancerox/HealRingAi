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
    private var heartRateCallback: (([String: Any]) -> Void)?
    private var heartRateEventSink: FlutterEventSink?
    private var lastHeartRate: Int?
    private var sameHeartRateTimer: Timer?
    
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
        
        // Add event channel handler
        let heartRateStreamHandler = StreamHandler()
        heartRateStreamHandler.onListen = { [weak self] (arguments: Any?, events: @escaping FlutterEventSink) -> FlutterError? in
            self?.heartRateEventSink = events
            return nil
        }
        
        heartRateStreamHandler.onCancel = { [weak self] (arguments: Any?) -> FlutterError? in
            self?.heartRateEventSink = nil
            return nil
        }
        
        // Setup heart rate event channel
        let eventChannel = FlutterEventChannel(name: "com.yourcompany.heartrate/stream",
                                               binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(heartRateStreamHandler)
        
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
            case "getSleepData":
                self.handleGetSleepData(call: call, result: result)
            case "getBatteryLevel":
                self.handleGetBatteryLevel(result: result)
            case "startMeasurement":
                self.handleStartMeasuring(call: call, result: result)
            case "startHeartRateStream":
                self.handleStartHeartRateStream(result: result)
            case "getCurrentSteps":
                self.handleGetCurrentSteps(result: result)
            case "getDailySteps":
                self.handleGetDailySteps(call: call, result: result)
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
            guard let self = self else { return }
            self.connectionEventSink = sink
            self.isEventChannelSetup = true
            
            // Send initial connection state immediately when stream is established
            if let peripheral = self.connectedPeripheral {
                switch peripheral.state {
                case .connecting:
                    self.sendConnectionState(peripheral, state: "connecting")
                case .connected:
                    self.sendConnectionState(peripheral, state: "connected")
                case .disconnecting:
                    self.sendConnectionState(peripheral, state: "disconnecting")
                case .disconnected:
                    self.sendConnectionState(peripheral, state: "disconnected")
                @unknown default:
                    self.sendConnectionState(peripheral, state: "unknown")
                }
            } else {
                // No device connected
                self.sendConnectionState(nil, state: "disconnected")
            }
            
            // Check for potential connections after sending initial state
            self.checkInitialConnectionState()
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
    
    // private func startKeepAliveTimer() {
    //     // Cancel any existing timer
    //     keepAliveTimer?.invalidate()
        
    //     // Start new timer to read RSSI periodically
    //     keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
    //         guard let self = self,
    //               let peripheral = self.connectedPeripheral,
    //               peripheral.state == .connected else {
    //             return
    //         }
            
    //         // Read RSSI to keep connection alive
    //         peripheral.readRSSI()
    //     }
    // }
    
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
        
        guard let peripheral = connectedPeripheral else {
            print("❌ No peripheral connected")
            result(FlutterError(
                code: "DEVICE_NOT_CONNECTED",
                message: "No device connected",
                details: nil
            ))
            return
        }
        
        let dayIndices = dayIndicesNS.map { NSNumber(value: $0) }
        
        // Create a strong reference to self to prevent premature deallocation
        let strongSelf = self
        
        ensurePeripheralAdded(peripheral: peripheral) {
            // Use a serial queue to ensure operations complete in order
            let serialQueue = DispatchQueue(label: "com.app.heartrate.queue")
            
            serialQueue.async {
                let semaphore = DispatchSemaphore(value: 0)
                var heartRateData: [[String: Any]] = []
                var bloodOxygenData: [[String: Any]] = []
                var heartRateError: Error?
                
                // Get Heart Rate Data
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
                        semaphore.signal()
                    },
                    fail: { 
                        heartRateError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to read heart rate data"])
                        semaphore.signal()
                    }
                )
                
                // Wait for heart rate data to complete
                semaphore.wait()
                
                // Process blood oxygen data only after heart rate data is complete
                if heartRateError == nil {
                    strongSelf.processBloodOxygenData(dayIndices: dayIndicesNS, currentIndex: 0) { finalBloodOxygenData in
                        let combinedData: [String: Any] = [
                            "heartRateData": heartRateData,
                            "bloodOxygenData": finalBloodOxygenData
                        ]
                        
                        DispatchQueue.main.async {
                            result(combinedData)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        result(FlutterError(
                            code: "DATA_READ_FAILED",
                            message: "Failed to read heart rate data: \(heartRateError?.localizedDescription ?? "")",
                            details: nil
                        ))
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
        
        QCSDKCmdCreator.getBloodOxygenData(byDayIndex: dayIndex) { (models, error) in
            var newData = accumulatedData
            
            if let error = error {
                print("Warning: Failed to get blood oxygen data for day \(dayIndex): \(error.localizedDescription)")
                // Don't add anything to newData when there's an error
            } else if let models = models, !models.isEmpty {
                let oxygenData = (models as NSArray).compactMap { item -> [String: Any]? in
                    guard let model = item as? QCBloodOxygenModel,
                          model.soa2 > 0 else { return nil }
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
            // If models is nil or empty, we don't add anything to newData
            
            // Process next index recursively
            self.processBloodOxygenData(
                dayIndices: dayIndices,
                currentIndex: currentIndex + 1,
                accumulatedData: newData,
                completion: completion
            )
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
    
    private func handleGetSleepData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("🔍 handleGetSleepData called")
        
        // Check device readiness
        guard isDeviceReadyForRequests() else {
            print("❌ Device not ready for requests")
            result(FlutterError(
                code: "DEVICE_NOT_READY",
                message: "Device is not ready for requests",
                details: nil
            ))
            return
        }
        
        // Validate arguments
        guard let args = call.arguments as? [String: Any],
              let dayIndex = args["dayIndex"] as? Int else {
            print("❌ Invalid arguments received")
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Invalid arguments",
                details: nil
            ))
            return
        }
        
        print("📅 Requesting sleep data for day index: \(dayIndex)")
        
        // Ensure peripheral is added before making request
        guard let peripheral = connectedPeripheral else {
            print("❌ No peripheral connected")
            result(FlutterError(
                code: "DEVICE_NOT_CONNECTED",
                message: "No device connected",
                details: nil
            ))
            return
        }
        
        print("🔌 Peripheral connected: \(peripheral.name ?? "Unknown")")
        print("📡 Connection state: \(peripheral.state.rawValue)")
        
        ensurePeripheralAdded(peripheral: peripheral) {
            print("✅ Peripheral added successfully, requesting sleep data...")
            
            QCSDKCmdCreator.getSleepDetailDataV2(byDay: dayIndex, sleepDatas: { sleepDict in
                print("📊 Received sleep data response")
                
                // Check for empty data first
                guard let dayKey = String(dayIndex).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let dailyData = sleepDict[dayKey],
                      !dailyData.isEmpty else {
                    print("⚠️ No sleep data found for day \(dayIndex)")
                    DispatchQueue.main.async {
                        result([])
                    }
                    return
                }
                
                let sleepDataResult = dailyData.map { model -> [String: Any] in
                    return [
                        "type": model.type.rawValue,
                        "typeString": {
                            switch model.type {
                            case .SLEEPTYPENONE: return "no_data"
                            case .SLEEPTYPESOBER: return "awake"
                            case .SLEEPTYPELIGHT: return "light"
                            case .SLEEPTYPEDEEP: return "deep"
                            case .SLEEPTYPEUNWEARED: return "not_worn"
                            @unknown default: return "unknown"
                            }
                        }(),
                        "startTime": model.happenDate ?? "",
                        "endTime": model.endTime ?? "",
                        "durationMinutes": model.total
                    ]
                }
                
                DispatchQueue.main.async {
                    print("✅ Successfully retrieved \(sleepDataResult.count) sleep records")
                    result(sleepDataResult)
                }
                
            }, fail: {
                print("❌ Failed to retrieve sleep data")
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "SLEEP_DATA_FAILED",
                        message: "Failed to retrieve sleep data",
                        details: nil
                    ))
                }
            })
        }
    }
    
    // Add this new handler method
    private func handleGetBatteryLevel(result: @escaping FlutterResult) {
        guard let peripheral = connectedPeripheral else {
            result(FlutterError(
                code: "DEVICE_NOT_CONNECTED",
                message: "No device connected",
                details: nil
            ))
            return
        }
        
        QCSDKCmdCreator.readBatterySuccess(
            { batteryLevel in
                result(batteryLevel)
            },
            failed: {
                result(FlutterError(
                    code: "BATTERY_READ_FAILED",
                    message: "Failed to read battery level",
                    details: nil
                ))
            }
        )
    }
    
   private func handleStartMeasuring(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Return immediately so Dart sees that the method was invoked
    result(["started": true])
    
    // 1) Measure Heart Rate
    QCSDKManager.shareInstance().startToMeasuring(withOperateType: .heartRate) { (hrSuccess, hrResult, hrError) in
        
        // Send heart-rate event
        if hrSuccess, let hrNumber = hrResult as? NSNumber {
            let hrEvent = [
                "dataType": "heartRate",
                "value": hrNumber.intValue,
                "isError": false,
                "errorCode": 0,
                "errorMessage": ""
            ] as [String : Any]
            self.heartRateEventSink?(hrEvent)
        } else {
            let hrEvent = [
                "dataType": "heartRate",
                "value": 0,
                "isError": true,
                "errorCode": (hrError as NSError?)?.code ?? -1,
                "errorMessage": hrError?.localizedDescription ?? "Heart rate measurement failed"
            ] as [String : Any]
            self.heartRateEventSink?(hrEvent)
        }
        
        // 2) Then measure Blood Oxygen
        QCSDKManager.shareInstance().startToMeasuring(withOperateType: .bloodOxygen) { (boSuccess, boResult, boError) in
            
            // Send blood-oxygen event
            if boSuccess, let boNumber = boResult as? NSNumber {
                let boEvent = [
                    "dataType": "bloodOxygen",
                    "value": boNumber.intValue,
                    "isError": false,
                    "errorCode": 0,
                    "errorMessage": ""
                ] as [String : Any]
                self.heartRateEventSink?(boEvent)
            } else {
                let boEvent = [
                    "dataType": "bloodOxygen",
                    "value": 0,
                    "isError": true,
                    "errorCode": (boError as NSError?)?.code ?? -1,
                    "errorMessage": boError?.localizedDescription ?? "Blood oxygen measurement failed"
                ] as [String : Any]
                self.heartRateEventSink?(boEvent)
            }
        }
    }
}
    
    private func handleStartHeartRateStream(result: @escaping FlutterResult) {
        // Start heart rate measurement
        QCSDKManager.shareInstance().startToMeasuring(withOperateType: .heartRate) { (hrSuccess, hrResult, hrError) in
            let hrEvent: [String: Any]
            if hrSuccess, let hrNumber = hrResult as? NSNumber {
                hrEvent = [
                    "dataType": "heartRate",
                    "value": hrNumber.intValue,
                    "isError": false,
                    "errorCode": 0,
                    "errorMessage": ""
                ]
            } else {
                hrEvent = [
                    "dataType": "heartRate",
                    "value": 0,
                    "isError": true,
                    "errorCode": (hrError as? NSError)?.code ?? -1,
                    "errorMessage": hrError?.localizedDescription ?? "Heart rate measurement failed"
                ]
            }
            self.heartRateEventSink?(hrEvent)
        }
        
        // Start blood oxygen measurement INDEPENDENTLY
        QCSDKManager.shareInstance().startToMeasuring(withOperateType: .bloodOxygen) { (boSuccess, boResult, boError) in
            let boEvent: [String: Any]
            if boSuccess, let boNumber = boResult as? NSNumber {
                boEvent = [
                    "dataType": "bloodOxygen",
                    "value": boNumber.intValue,
                    "isError": false,
                    "errorCode": 0,
                    "errorMessage": ""
                ]
            } else {
                boEvent = [
                    "dataType": "bloodOxygen",
                    "value": 0,
                    "isError": true,
                    "errorCode": (boError as? NSError)?.code ?? -1,
                    "errorMessage": boError?.localizedDescription ?? "Blood oxygen measurement failed"
                ]
            }
            self.heartRateEventSink?(boEvent)
        }
        
        result(nil)
    }
    
    // Add these new handler methods

    private func handleGetCurrentSteps(result: @escaping FlutterResult) {
        guard isDeviceReadyForRequests() else {
            result(FlutterError(
                code: "DEVICE_NOT_READY",
                message: "Device is not ready for requests",
                details: nil
            ))
            return
        }
        
        QCSDKCmdCreator.getCurrentSportSucess({ sportModel in
            // Print the model to see available properties
            print("Sport model: \(sportModel)")
            
            // Attempt to read values using Mirror to inspect the properties
            var stepsData: [String: Any] = [:]
            
            // Use Mirror to find property names
            let mirror = Mirror(reflecting: sportModel)
            for child in mirror.children {
                print("Property: \(child.label ?? "unknown") = \(child.value)")
            }
            
            // Set default values
            stepsData = [
                "steps": 0,
                "calories": 0,
                "distance": 0,
                "duration": 0
            ]
            
            // Try to access potential property names for steps
            if let value = sportModel.value(forKey: "step") as? Int {
                stepsData["steps"] = value
            } else if let value = sportModel.value(forKey: "steps") as? Int {
                stepsData["steps"] = value
            } else if let value = sportModel.value(forKey: "stepCount") as? Int {
                stepsData["steps"] = value
            }
            
            // Try to access potential property names for calories
            if let value = sportModel.value(forKey: "calorie") as? Int {
                stepsData["calories"] = value
            } else if let value = sportModel.value(forKey: "calories") as? Int {
                stepsData["calories"] = value
            } else if let value = sportModel.value(forKey: "calorieCount") as? Int {
                stepsData["calories"] = value
            }
            
            // Try to access potential property names for distance
            if let value = sportModel.value(forKey: "distance") as? Int {
                stepsData["distance"] = value
            }
            
            // Try to access potential property names for duration
            if let value = sportModel.value(forKey: "duration") as? Int {
                stepsData["duration"] = value
            } else if let value = sportModel.value(forKey: "sportTime") as? Int {
                stepsData["duration"] = value
            } else if let value = sportModel.value(forKey: "time") as? Int {
                stepsData["duration"] = value
            }
            
            result(stepsData)
        }, failed: {
            result(FlutterError(
                code: "STEPS_READ_FAILED",
                message: "Failed to read current steps",
                details: nil
            ))
        })
    }

    private func handleGetDailySteps(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dayIndex = args["dayIndex"] as? Int else {
            result(FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Invalid day index",
                details: nil
            ))
            return
        }
        
        guard isDeviceReadyForRequests() else {
            result(FlutterError(
                code: "DEVICE_NOT_READY",
                message: "Device is not ready for requests",
                details: nil
            ))
            return
        }
        
        QCSDKCmdCreator.getOneDaySport(by: dayIndex, success: { sportModel in
            // Print the model to see available properties
            print("Daily sport model: \(sportModel)")
            
            // Default values
            var stepsData: [String: Any] = [
                "steps": 0,
                "calories": 0,
                "distance": 0,
                "duration": 0,
                "date": sportModel.value(forKey: "date") as? String ?? ""
            ]
            
            // Use Mirror to find property names
            let mirror = Mirror(reflecting: sportModel)
            for child in mirror.children {
                print("Property: \(child.label ?? "unknown") = \(child.value)")
            }
            
            // Try to access potential property names for steps
            if let value = sportModel.value(forKey: "step") as? Int {
                stepsData["steps"] = value
            } else if let value = sportModel.value(forKey: "steps") as? Int {
                stepsData["steps"] = value
            } else if let value = sportModel.value(forKey: "stepCount") as? Int {
                stepsData["steps"] = value
            }
            
            // Try to access potential property names for calories
            if let value = sportModel.value(forKey: "calorie") as? Int {
                stepsData["calories"] = value
            } else if let value = sportModel.value(forKey: "calories") as? Int {
                stepsData["calories"] = value
            } else if let value = sportModel.value(forKey: "calorieCount") as? Int {
                stepsData["calories"] = value
            }
            
            // Try to access potential property names for distance
            if let value = sportModel.value(forKey: "distance") as? Int {
                stepsData["distance"] = value
            }
            
            // Try to access potential property names for duration
            if let value = sportModel.value(forKey: "duration") as? Int {
                stepsData["duration"] = value
            } else if let value = sportModel.value(forKey: "sportTime") as? Int {
                stepsData["duration"] = value
            } else if let value = sportModel.value(forKey: "time") as? Int {
                stepsData["duration"] = value
            }
            
            result(stepsData)
        }, fail: {
            result(FlutterError(
                code: "STEPS_READ_FAILED",
                message: "Failed to read steps for day \(dayIndex)",
                details: nil
            ))
        })
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
    
    private func sendConnectionState(_ peripheral: CBPeripheral?, state: String) {
        var deviceInfo: [String: Any] = [
            "connected": state == "connected",
            "state": state
        ]
        
        if let peripheral = peripheral {
            deviceInfo["device"] = [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": deviceRSSI[peripheral.identifier.uuidString] ?? 0,
                "manufacturerData": ""
            ]
        } else {
            deviceInfo["device"] = [
                "id": "",
                "name": "No Device",
                "rssi": 0,
                "manufacturerData": ""
            ]
        }
        
        connectionEventSink?(deviceInfo)
    }
    
    private func sendConnectionState(peripheral: CBPeripheral, isConnected: Bool) {
        sendConnectionState(peripheral, state: isConnected ? "connected" : "disconnected")
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
        
        // Cancel connection timer immediately
        connectionTimer?.invalidate()
        connectionTimer = nil
        
        // Add to SDK immediately without delay
        QCSDKManager.shareInstance().add(peripheral) { _ in
            self.isPeripheralAdded = true
            
            print("✅ Peripheral added to SDK")
            self.sendConnectionState(peripheral: peripheral, isConnected: true)
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
        
        // Clean up SDK state
        QCSDKManager.shareInstance().remove(peripheral)
        
        isPeripheralAdded = false
        
        // Attempt immediate reconnection if disconnection was unexpected
        if lastConnectedDeviceId != nil && error != nil {
            print("Unexpected disconnection - attempting immediate reconnection...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                print("trying to reconnect!!!!!!")
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
            print("❌ Device not ready - Connected: \(connectedPeripheral?.state == .connected), Added: \(isPeripheralAdded)")
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


class StreamHandler: NSObject, FlutterStreamHandler {
    var onListen: ((Any?, @escaping FlutterEventSink) -> FlutterError?)?
    var onCancel: ((Any?) -> FlutterError?)?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return onListen?(arguments, events)
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return onCancel?(arguments)
    }
}
