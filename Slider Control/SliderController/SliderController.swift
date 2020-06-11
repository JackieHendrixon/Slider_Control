//
//  SliderController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import Foundation
import CoreBluetooth
import UIKit

protocol SliderControllerDelegate {
    func didConnect()
    
    func didDisconnect()
    
    func didCalibrate()
}

class SliderController {
    
    static let instance = SliderController()
    
    // MARK: Properties
    
    let slider: Slider = Slider()
    
    private let bluetoothService: BluetoothService = BluetoothService()
    
    var timer = Timer()
    
    var refreshTime: TimeInterval = 0.1
    
    // SliderControllerDelegate
    var delegates = [SliderControllerDelegate]()
    
    // MARK: Init
    
    init() {
        bluetoothService.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateCurrentTimecode), name: .didUpdateCurrentTimecode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimer), name: .didSwitchMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimer), name: .didUpdateConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchSliderMode), name: .didSwitchMode, object: nil)
    }
    
    // MARK: Public methods
    
    // Starts scanning and connects to a device after finding one.
    func startLookingForConnection() {
        bluetoothService.startScanning()
    }
    
    func disconnect() {
        if slider.isConnected{
            if let device = bluetoothService.getDevices().first(where: {$0.isConnected == true }) {
                bluetoothService.disconnect(from: device )
            }
        }
    }
    
    @objc func updateTimer(){
        if slider.mode == .live && slider.isConnected {
            timer = Timer.scheduledTimer(timeInterval: refreshTime, target: self, selector: #selector(self.getCurrentSliderPosition), userInfo: nil, repeats: true)
            
        } else if timer.isValid {
            timer.invalidate()
        }
    }
    
    // Asks for calibration information and sets the value.
    func getCalibration() {
        write(string: SliderCommandSign.getCalibration.rawValue)
    }
    
    @objc func getCurrentSliderPosition(){
        write(string: SliderCommandSign.getCurrentPosition.rawValue)
    }
    
    // Moves slider to desired position.
    func moveTo(position value: Parameters) {
        if slider.isConnected {
            if let steps = slider.calibration?.convertValueToSteps(value: value) {
                var command = SliderCommandSign.x.rawValue + String(Int(steps.x))
                command += SliderCommandSign.pan.rawValue + String(Int(steps.pan))
                command += SliderCommandSign.tilt.rawValue + String(Int(steps.tilt))
                command += SliderCommandSign.end.rawValue
                
                write(string: command)
            } else {
                debugPrint("Error in SliderController: No calibration info.")
            }
        }
    }
    
    // Moves slider with desired speed.
    func moveOn(gear: Int, parameter: String) {
        if slider.isConnected {
            var command: String
            switch parameter {
            case "x":
                switch gear {
                case -3:
                    write(string: "b")
                    write(string: "3")
                case -2:
                    write(string: "b")
                    write(string: "2")
                case -1:
                    write(string: "b")
                    write(string: "1")
                case 0:
                    write(string: "0")
                case 1:
                    write(string: "a")
                    write(string: "1")
                case 2:
                    write(string: "a")
                    write(string: "2")
                case 3:
                    write(string: "a")
                    write(string: "3")
                default: break
                }
                
                
            case "pan":
                switch gear {
                case -3:
                    write(string: "d")
                    write(string: "6")
                case -2:
                    write(string: "d")
                    write(string: "5")
                case -1:
                    write(string: "d")
                    write(string: "4")
                case 0:
                    write(string: "<")
                case 1:
                    write(string: "c")
                    write(string: "4")
                case 2:
                    write(string: "c")
                    write(string: "5")
                case 3:
                    write(string: "c")
                    write(string: "6")
                default: break
                }
                
            case "tilt":
                switch gear {
                case -3:
                    write(string: "e")
                    write(string: "9")
                case -2:
                    write(string: "e")
                    write(string: "8")
                case -1:
                    write(string: "e")
                    write(string: "7")
                case 0:
                    write(string: ">")
                case 1:
                    write(string: "f")
                    write(string: "7")
                case 2:
                    write(string: "f")
                    write(string: "8")
                case 3:
                    write(string: "f")
                    write(string: "9")
                default: break
                }
                
            default: command = ""
            }
        }

    }
    
    // Writes string to the device.
    func write(string: String) {
        let serviceID = CBUUID(string: SliderID.service)
        let characteristicID = CBUUID(string: SliderID.characteristic)
        
        if let device = bluetoothService.getDevices().first(where: {$0.isConnected}){
            if let service = device.services.first(where: {
                $0.service.uuid == serviceID}) {
              
                if let characteristic = service.characteristics.first(where: {
                    $0.characteristic.uuid == characteristicID})?.characteristic {
                    let data = string.data(using: .utf8)
                    device.peripheral.writeValue(data!, for: characteristic, type: .withoutResponse)
                }
            }
        }
    }

    // MARK: - Private functions
    
    // Processes feedback every time it is updated
    private func processFeedback(feedback: String) {
        
        switch feedback.first {
        case "@":
            
            let parameters = decodeParameters(string: feedback)
            slider.calibration = Calibration(deviceStepsRange: parameters,
                                             appValueRange: Parameters(x: 100, pan: 360, tilt: 90))
            print("Calibration info: \(slider.calibration!)" )
            for delegate in delegates{
                delegate.didCalibrate()
            }
            
        case "!":
            print("Is ready: \(feedback)")
            
        case "#":
            let parameters = decodeParameters(string: feedback)
            if let calibration = slider.calibration {
                slider.currentPosition = calibration.convertStepsToValue(steps: parameters)
            }
            
        default:
            print("Unspecified value: \(feedback)")
        }
    }
    
    private func decodeParameters(string: String) -> Parameters {

        var range = (string.firstIndex(of: SliderCommandSign.x.rawValue.first!)!)..<(string.firstIndex(of: SliderCommandSign.pan.rawValue.first!)!)
        var substring = string[range]
        substring = substring.suffix(substring.count-1)
        let x = Float(String(substring))!
        
        range = (string.firstIndex(of: SliderCommandSign.pan.rawValue.first!)!)..<(string.firstIndex(of: SliderCommandSign.tilt.rawValue.first!)!)
        substring = string[range]
        substring = substring.suffix(substring.count-1)
        let pan = Float(String(substring))!
        
        range = (string.firstIndex(of: SliderCommandSign.tilt.rawValue.first!)!)..<(string.firstIndex(of: SliderCommandSign.end.rawValue.first!)!)
        substring = string[range]
        substring = substring.suffix(substring.count-1)
        let tilt = Float(String(substring))!
        
        return Parameters(x: x, pan: pan, tilt: tilt)
    }
    
    @objc func switchSliderMode(){
        if slider.isConnected {
            if slider.mode == .live {
                write(string: SliderCommandSign.liveMode.rawValue)
                
            } else {
                write(string: SliderCommandSign.sequenceMode.rawValue)
                print("Switching mode")
                if slider.isOnline {
                    moveTo(position: Sequence.instance.calculateParameters(for: CurrentTimecode.current))
                }
            }
        }
    }
    
    
    // Can be done better
    @objc private func didUpdateCurrentTimecode() {
        if slider.isOnline && slider.mode == .sequence {
            moveTo(position: NewSequenceModel.instance.calculateParameters(for: CurrentTimecode.current))
        }
    }
}


// MARK: BluetoothServiceDelegate

extension SliderController: BluetoothServiceDelegate {
    func didPowerStateUpdate(isPowerOn: Bool) {
        debugPrint("Bluetooth power on: \(isPowerOn)" )
    }
    
    func didDeviceUpdate() {
        if !self.slider.isConnected{
            if let device = bluetoothService.getDevices().first(where: {$0.name == SliderID.deviceName }) {
                bluetoothService.connect(to: device)
                bluetoothService.stopScanning()
            }
        }
    }
    
    func didConnect(with device: Device) {
        self.slider.isConnected = true
        for delegate in delegates{
            delegate.didConnect()
        }
        write(string: SliderCommandSign.liveMode.rawValue)
    }
    
    func didDisconnect(with device: Device) {
        self.slider.isConnected = false
        self.slider.isOnline = false
        for delegate in delegates{
            delegate.didDisconnect()
        }
    }
    
    func didUpdateValue(value: String) {
        self.slider.feedback = value
        self.processFeedback(feedback: value)
    }
}



extension SliderController: JoystickDelegate{
    func didUpdate(data: JoystickData, sender: Joystick) {
        
        if  slider.mode == .live {
            
            switch sender.accessibilityIdentifier {
            case "leftJoystick":
                
                let maxGears = SliderController.instance.slider.maxGears
             
                let gear = Int(data.x * CGFloat(maxGears+1)/100)
               
                if slider.currentSpeed.x != Float(gear)
                {
                    print("x: \(gear)")
                    slider.currentSpeed.x = Float(gear)
                    print(slider.currentSpeed)
                    moveOn(gear: Int(slider.currentSpeed.x), parameter: "x" )
                }

            case "rightJoystick":
                let maxGears = SliderController.instance.slider.maxGears
                
                let gearPan = Int(data.x * CGFloat(maxGears+1)/100)
                if slider.currentSpeed.pan != Float(gearPan)
                {
                    print("pan: \(gearPan) ")
                    slider.currentSpeed.pan = Float(gearPan)
                    
                    print(slider.currentSpeed)
                    moveOn(gear: Int(slider.currentSpeed.pan), parameter: "pan" )
                }
               
                let gearTilt = Int(data.y * CGFloat(maxGears+1)/100)
                if  slider.currentSpeed.tilt != Float(gearTilt) {
                    print("tilt: \(gearTilt)")
                    slider.currentSpeed.tilt = Float(gearTilt)
                    print(slider.currentSpeed)
                    moveOn(gear: Int(slider.currentSpeed.tilt), parameter: "tilt" )
                }
                break
            default:
                break
            }
        }
    }
}
