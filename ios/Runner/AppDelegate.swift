import UIKit
import Flutter
import CoreBluetooth

@main
@objc class AppDelegate: FlutterAppDelegate, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var methodChannel: FlutterMethodChannel!
    private var scanEventChannel: FlutterEventChannel!
    private var connectionEventChannel: FlutterEventChannel!
    private var scanEventSink: FlutterEventSink?
    private var connectionEventSink: FlutterEventSink?
    private var connectedPeripheral: CBPeripheral?
    private let kLastConnectedDeviceKey = "LastConnectedDeviceKey"
    private var discoveredDevices: [[String: Any]] = []
    
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
        
        // Initialize CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
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
            // Send initial state
            sink?(self?.centralManager.state == .poweredOn)
        }))
    }
    
    // MARK: - Method Channel Handlers
    
    private func handleCheckPermissions(result: @escaping FlutterResult) {
        if #available(iOS 13.1, *) {
            let status = CBCentralManager.authorization
            switch status {
            case .allowedAlways:
                result(true)
            case .denied, .restricted:
                result(false)
            case .notDetermined:
                // In iOS, permission will be requested when scanning starts
                result(true)
            @unknown default:
                result(false)
            }
        } else {
            // Before iOS 13, no explicit permission was required
            result(true)
        }
    }
    
    private func handleRequestPermissions(result: @escaping FlutterResult) {
        // On iOS, permissions are requested automatically when needed
        // Just return current status
        handleCheckPermissions(result: result)
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
        
        // Store device ID in UserDefaults when explicitly connecting
        lastConnectedDeviceId = deviceId
        print("Storing last connected device ID: \(deviceId)") // Debug log
        
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first else {
            result(FlutterError(
                code: "DEVICE_NOT_FOUND",
                message: "Device not found",
                details: nil
            ))
            return
        }
        
        connectedPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
        result(nil)
    }
    
    private func handleDisconnectDevice(result: @escaping FlutterResult) {
        // Clear stored device ID when explicitly disconnecting
        lastConnectedDeviceId = nil
        print("Clearing last connected device ID") // Debug log
        
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
        }
        result(nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let isEnabled = central.state == .poweredOn
        print("Bluetooth state changed - Powered On: \(isEnabled)") // Debug log
        connectionEventSink?(isEnabled)
        
        // Attempt to reconnect when Bluetooth is powered on
        if isEnabled, let deviceId = lastConnectedDeviceId {
            print("Attempting to reconnect to device ID: \(deviceId)") // Debug log
            
            guard let uuid = UUID(uuidString: deviceId),
                  let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first else {
                print("Failed to find peripheral with ID: \(deviceId)") // Debug log
                return
            }
            
            print("Found peripheral, attempting connection: \(peripheral.name ?? "Unknown")") // Debug log
            connectedPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
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
        
        let device: [String: Any] = [
            "id": peripheral.identifier.uuidString,
            "name": name,
            "rssi": RSSI.intValue,
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
        print("Connected to device: \(peripheral.name ?? "Unknown")") // Debug log
        
        // Create device info dictionary with the actual peripheral name
        let deviceInfo: [String: Any] = [
            "connected": true,
            "device": [
                "id": peripheral.identifier.uuidString,
                "name": peripheral.name ?? "Unknown Device",
                "rssi": 0,
                "manufacturerData": ""
            ]
        ]
        connectionEventSink?(deviceInfo)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Device disconnected - Last known ID: \(lastConnectedDeviceId ?? "None")") // Debug log
        if let error = error {
            print("Disconnect error: \(error.localizedDescription)") // Debug log
        }
        
        // Don't clear lastConnectedDeviceId here to allow auto-reconnection
        connectedPeripheral = nil
        connectionEventSink?(false)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        connectionEventSink?(false)
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
