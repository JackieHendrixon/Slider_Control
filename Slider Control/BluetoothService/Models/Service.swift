//
//  Service.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import Foundation
import CoreBluetooth

class Service {
    
    public var uuid: String
    public var service: CBService
    public var characteristics: [Characteristic] = []
    
    public init(uuid: String, service: CBService) {
        self.uuid = uuid
        self.service = service
    }
}

class Characteristic {
    
    public var uuid: String
    public var characteristic: CBCharacteristic
    
    public init(uuid: String, characteristic: CBCharacteristic) {
        self.uuid = uuid
        self.characteristic = characteristic
    }
}
