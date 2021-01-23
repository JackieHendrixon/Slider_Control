//
//  SettingsViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class SettingsViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = .clear
        tableView.allowsSelection = false
        
        SliderController.instance.delegates.append(self)
        
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.handleTapGesture(_:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func handleTapGesture(_ gestureRecognizer : UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsSections.connection.rawValue: return 2
        case SettingsSections.mode.rawValue: return 1
        case SettingsSections.calibration.rawValue: return 3
        case SettingsSections.timecode.rawValue: return 2
        case SettingsSections.joystick.rawValue: return 1
        case SettingsSections.credits.rawValue: return 0
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SettingsSections.connection.rawValue: return "Connection"
        case SettingsSections.mode.rawValue: return "Mode"
        case SettingsSections.calibration.rawValue: return "Calibration"
        case SettingsSections.timecode.rawValue: return "Timecode"
        case SettingsSections.joystick.rawValue: return "Joystick"
        case SettingsSections.credits.rawValue: return "Credits"
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SettingsSections.connection.rawValue: return cellsForConnection(indexPath: indexPath)
        case SettingsSections.mode.rawValue: return cellsForMode(indexPath: indexPath)
        case SettingsSections.calibration.rawValue: return cellsForCalibration(indexPath: indexPath)
        case SettingsSections.timecode.rawValue: return cellsForTimecode(indexPath: indexPath)
        case SettingsSections.joystick.rawValue: return cellsForJoystick(indexPath: indexPath)
        case SettingsSections.credits.rawValue: return cellsForCredits(indexPath: indexPath)
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
        returnedView.backgroundColor = .darkGray

        let label = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.bounds.width, height: 25))
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        switch section {
        case SettingsSections.connection.rawValue: label.text = "Connection"
        case SettingsSections.mode.rawValue: label.text = "Mode"
        case SettingsSections.calibration.rawValue: label.text = "Calibration"
        case SettingsSections.timecode.rawValue: label.text = "Timecode"
        case SettingsSections.joystick.rawValue: label.text = "Joystick"
        case SettingsSections.credits.rawValue: label.text = "Credits"
        default: label.text = ""
        }
        returnedView.addSubview(label)
        return returnedView
    }
    
    func cellsForConnection(indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldSettingsCell", for: indexPath) as! TextFieldTableViewCell
            cell.label.text = "Device name"
            cell.textField.placeholder = SliderID.deviceName
            cell.textField.accessibilityIdentifier = "deviceNameTextField"
            cell.textField.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchSettingsCell", for: indexPath) as! SwitchTableViewCell
            cell.label.text = "Enable connection"
            cell.control.setOn(SliderController.instance.slider.isConnected, animated: true)
            cell.control.addTarget(self, action: #selector(self.connectionAction(connectionSwitch:)), for: .valueChanged)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func cellsForMode(indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "segmentedControlSettingsCell", for: indexPath) as! SegmentedControlTableViewCell
        cell.label.text = "Mode"
        cell.control.removeAllSegments()
        cell.control.insertSegment(withTitle: "live", at: 0, animated: false)
        cell.control.insertSegment(withTitle: "sequence", at: 1, animated: false)
        
        switch SliderController.instance.slider.mode {
        case .live : cell.control.selectedSegmentIndex = 0
        case .sequence : cell.control.selectedSegmentIndex = 1
        }
        cell.control.addTarget(self, action: #selector(modeAction(control:)), for: .valueChanged)
        return cell
        
    }
    
    func cellsForCalibration(indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "rangeSettingsCell", for: indexPath) as! RangeTableViewCell
        switch indexPath.row {
        case 0:
            cell.label.text = "Translation"
            cell.fromTextField.placeholder = String(Keyframe.parametersRange.min.x)
            cell.fromTextField.accessibilityIdentifier = "xFromTextField"
            cell.toTextField.placeholder = String(Keyframe.parametersRange.max.x)
            cell.toTextField.accessibilityIdentifier = "xToTextField"
        case 1:
            cell.label.text = "Panorama"
            cell.fromTextField.placeholder = String(Keyframe.parametersRange.min.pan)
            cell.fromTextField.accessibilityIdentifier = "panFromTextField"
            cell.toTextField.placeholder = String(Keyframe.parametersRange.max.pan)
            cell.toTextField.accessibilityIdentifier = "panToTextField"
        case 2:
            cell.label.text = "Tilt"
            cell.fromTextField.placeholder = String(Keyframe.parametersRange.min.tilt)
            cell.fromTextField.accessibilityIdentifier = "tiltFromTextField"
            cell.toTextField.placeholder = String(Keyframe.parametersRange.max.tilt)
            cell.toTextField.accessibilityIdentifier = "panToTextField"
        default:
            break
        }
        cell.toTextField.delegate = self
        cell.fromTextField.delegate = self
        
        return cell
    }
    
    func cellsForTimecode(indexPath: IndexPath) -> UITableViewCell{
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldSettingsCell", for: indexPath) as! TextFieldTableViewCell
            cell.label.text = "FPS"
            cell.textField.placeholder = String(Timecode.FPS)
            cell.textField.accessibilityIdentifier = "FPSTextField"
            cell.textField.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "segmentedControlSettingsCell", for: indexPath) as! SegmentedControlTableViewCell
            cell.label.text = "Timecode format"
            cell.control.removeAllSegments()
            cell.control.insertSegment(withTitle: "min:sec:frame", at: 0, animated: false)
            cell.control.insertSegment(withTitle: "total frames", at: 1, animated: false)
            if Timecode.fullFormat {
                cell.control.selectedSegmentIndex = 0
            } else {
                cell.control.selectedSegmentIndex = 1
            }
            cell.control.addTarget(self, action: #selector(timecodeFormatAction(control:)), for: .valueChanged)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func cellsForJoystick(indexPath: IndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldSettingsCell", for: indexPath) as! TextFieldTableViewCell
        cell.label.text = "Size"
        cell.textField.placeholder = String(100)
        return cell
    }
    
    
    func cellsForCredits(indexPath: IndexPath) -> UITableViewCell{
        
        return  UITableViewCell()
        
    }
    
    @objc func connectionAction(connectionSwitch: UISwitch) {
        if connectionSwitch.isOn {
            if !SliderController.instance.slider.isConnected {
                SliderController.instance.startLookingForConnection()
            }
        } else {
            if SliderController.instance.slider.isConnected {
                SliderController.instance.disconnect()
            }
        }
    }
    
    @objc func modeAction(control: UISegmentedControl) {
        if control.selectedSegmentIndex == 0 {
            SliderController.instance.slider.mode = .live
        } else {
            SliderController.instance.slider.mode = .sequence
        }
        
    }
    @objc func timecodeFormatAction(control: UISegmentedControl) {
        if control.selectedSegmentIndex == 0 {
            Timecode.fullFormat = true
        }
        else {
            Timecode.fullFormat = false
        }
    }
}

extension SettingsViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            switch textField.accessibilityIdentifier {
                
            case "deviceNameTextField":
                if text != "" {
                    SliderID.deviceName = text
                    textField.placeholder = SliderID.deviceName
                }
                
            case "xFromTextField":
                Keyframe.parametersRange.min.x = Float(text) ?? Keyframe.parametersRange.min.x
                textField.placeholder = String(Keyframe.parametersRange.min.x)
            case "xToTextField":
                Keyframe.parametersRange.max.x = Float(text) ?? Keyframe.parametersRange.max.x
                textField.placeholder = String(Keyframe.parametersRange.max.x)
            case "panFromTextField":
                Keyframe.parametersRange.max.pan = Float(text) ?? Keyframe.parametersRange.max.pan
                textField.placeholder = String(Keyframe.parametersRange.max.pan)
            case "panToTextField":
                Keyframe.parametersRange.min.pan = Float(text) ?? Keyframe.parametersRange.min.pan
                textField.placeholder = String(Keyframe.parametersRange.min.pan)
            case "tiltFromTextField":
                Keyframe.parametersRange.min.tilt = Float(text) ?? Keyframe.parametersRange.min.tilt
                textField.placeholder = String(Keyframe.parametersRange.min.tilt)
            case "tiltToTextField":
                Keyframe.parametersRange.max.tilt = Float(text) ?? Keyframe.parametersRange.max.tilt
                textField.placeholder = String(Keyframe.parametersRange.max.tilt)
            case "FPSTextField":
                Timecode.FPS = Int(text) ?? Timecode.FPS
                textField.placeholder = String(Timecode.FPS)
            default:
                return
            }
            textField.text = nil
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
             if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
            }
        }
    }
}

enum SettingsSections: Int, CaseIterable {
    case connection = 0,
     mode,
    calibration,
    timecode,
    joystick,
    credits
}

extension SettingsViewController: SliderControllerDelegate{
    func didConnect() {
        let indexPath = IndexPath(row: 1, section: SettingsSections.connection.rawValue)
        if let cell  = tableView(tableView, cellForRowAt: indexPath) as? SwitchTableViewCell {
            cell.control.setOn(true, animated: true)
        }
        
    }
    
    func didDisconnect() {
        let indexPath = IndexPath(row: 1, section: SettingsSections.connection.rawValue)
        if let cell  = tableView(tableView, cellForRowAt: indexPath) as? SwitchTableViewCell {
            cell.control.setOn(false, animated: true)
        }
    }
    
    func didCalibrate() {
        
    }
}

extension SettingsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        return touch.view == gestureRecognizer.view
    }
}
