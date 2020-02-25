//
//  BluetoothService.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation
import CoreBluetooth


// Delegate protocol designed for communication with Slider class
protocol BluetoothServiceDelegate: class {
    // Called when 'CBCentralManager' changes state.
    func didPowerStateUpdate(isPowerOn: Bool)
    
    // Called when new device has been discovered or rssi value of the existing has been updated
    func didDeviceUpdate()
    
    // Called when 'CBCentralManager' connects with the device
    func didConnect(with device: Device)
    
    // Called when 'CBCentralManager' disconnects from the device
    func didDisconnect(with device: Device)
    
    // Called when updated the LED state value.
    func didUpdateValue(value: String)
    
}

// Class responsible for Bluetooth Service, used in Slider class.
class BluetoothService: NSObject {
    
    // MARK: Properties
    
    private var centralManager: CBCentralManager!
    
    private var devices: [Device] = []
    
    public weak var delegate: BluetoothServiceDelegate?
    
    
    // MARK: Init
    
    public override init() {
        super.init()
        
        // Tip: Perform Bluetooth tasks on background queue
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        self.centralManager = CBCentralManager(delegate:self, queue:backgroundQueue)
    }
    
    public init(delegate: BluetoothServiceDelegate) {
        super.init()
        
        // Tip: Perform Bluetooth tasks on background queue
        let backgroundQueue = DispatchQueue.global(qos: .background)
        
        self.centralManager = CBCentralManager(delegate:self, queue:backgroundQueue)
        self.delegate = delegate
    }
    
    // MARK: Public methods
    
    public func startScanning() {
        guard self.isPowerOn() else {
            debugPrint("[Error: BTService: isPowerOn = false]")
            return}
        debugPrint("BTService: Start scanning")
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func stopScanning() {
        guard self.isPowerOn() else {return}
        debugPrint("BTService: Stop scanning")
        self.centralManager.stopScan()
    }
    
    public func getDevices() -> [Device] {
        return self.devices
    }
    
    public func isPowerOn() -> Bool {
        return self.centralManager.state == .poweredOn
    }
    
    public func  isScanning() -> Bool {
        return self.centralManager.isScanning
    }
    
    public func connect(to device: Device) {
        guard self.isPowerOn() else {return}
        debugPrint("BTService: will connect to \(device.name)")
        self.centralManager.connect(device.peripheral, options: nil)
    }
    
    public func disconnect(from device: Device) {
        guard self.isPowerOn() else {return}
        debugPrint("BTService: will disconnect from \(device.name)")
        self.centralManager.cancelPeripheralConnection(device.peripheral)
    }
    
    public func write(data: Data, for characteristic: CBCharacteristic, to device: Device) {
        device.peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    // MARK: Private methods
    
    // Matching 'CBPeripheral' with 'Device' by uuid
    private func matchPeripheral(_ peripheral: CBPeripheral) -> Device? {
        return self.devices.first(where: {$0.peripheral == peripheral})
    }
    
    // Matching 'CBService' with 'Service' of the device by uuid
    private func matchService(_ service: CBService, for device: Device) -> Service? {
        return device.services.first(where: {$0.service == service})
    }
}

// MARK: CBCentralManagerDelegate

extension BluetoothService: CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.delegate?.didPowerStateUpdate(isPowerOn: central.state == .poweredOn)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        /** Received Signal Strength Indicator (RSSI)
         is a measurement of the power present in a received radio signal */
        
        // Retrieve the peripheral nameform the advertisement data
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            debugPrint("[Peripheral Device]: - \(peripheralName)")
            
            // If device already created just update RSSI.
            if let existingDevice = self.devices.filter({$0.name == peripheralName}).first {
                
                // Update RSSI.
                existingDevice.add(RSSI)
            } else {
                let device = Device(uuid: peripheral.identifier.uuidString, name: peripheralName, peripheral: peripheral)
                device.add(RSSI)
                self.devices.append(device)
            }
            
            DispatchQueue.main.async {
                self.delegate?.didDeviceUpdate()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugPrint("[Connect] - \(peripheral.name!)")
        
        if let device = self.matchPeripheral(peripheral) {
            device.isConnected = true
            device.peripheral.delegate = self
            
            device.peripheral.discoverServices([])
            
            DispatchQueue.main.async {
                self.delegate?.didConnect(with: device)
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        debugPrint("[Disconnect] - \(peripheral.name!)]")
        
        if let device = self.matchPeripheral(peripheral) {
            device.isConnected = false
            
            DispatchQueue.main.async {
                self.delegate?.didDisconnect(with: device)
            }
        }
    }
}
// MARK: CBPeripheralDelegate

extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        guard let device = self.matchPeripheral(peripheral) else {return}
        
        for service in services {
            debugPrint("[Service]: - \(service)")
            let deviceService = Service(uuid: service.uuid.uuidString, service: service)
            device.services.append(deviceService)
            
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        guard let device = self.matchPeripheral(peripheral) else {return}
        guard let deviceService = self.matchService(service, for: device) else {return}
        
        for characteristic in characteristics {
            debugPrint("[Characteristic]: - \(characteristics)")
            let deviceCharacteristic = Characteristic(uuid: characteristic.uuid.uuidString, characteristic: characteristic)
            deviceService.characteristics.append(deviceCharacteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else {return}
        
        DispatchQueue.main.async {
            debugPrint("[Value]: - value \(String(decoding: value, as: UTF8.self))")
            self.delegate?.didUpdateValue(value: String(decoding: value, as: UTF8.self))
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
