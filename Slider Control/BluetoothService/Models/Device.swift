//
//  Device.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import Foundation
import CoreBluetooth

class Device: Equatable{
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.name == rhs.name
    }
    
    public var name: String
    public var rssiValues: [(date: Date, rssi: Double)] = []
    public var isConnected: Bool = false
    public var uuid: String
    public var services: [Service] = []
    public var peripheral: CBPeripheral
    
    public init(uuid: String, name: String, peripheral: CBPeripheral){
        self.name = name
        self.uuid = uuid
        self.peripheral = peripheral
    }
    
    // Adding RSSI value with timestamp
    public func add(_ RSSIvalue: NSNumber) {
        let rssi = Double(truncating: RSSIvalue)
        self.rssiValues.append((date: Date(), rssi:rssi))
        
        // Take only 3 last elements
        self.rssiValues = Array(self.rssiValues.suffix(3)) // Needs constant
    }
    
}
