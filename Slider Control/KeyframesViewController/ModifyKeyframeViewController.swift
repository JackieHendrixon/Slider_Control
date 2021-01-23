//
//  ModifyKeyframeViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class ModifyKeyframeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var keyframe: Keyframe?
    var indexPath: IndexPath?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var picker: UIPickerView!
    
    
    @IBOutlet weak var xSlider: UISlider!
    @IBOutlet weak var xValue: UILabel!
    @IBOutlet weak var panSlider: UISlider!
    @IBOutlet weak var panValue: UILabel!
    @IBOutlet weak var tiltSlider: UISlider!
    @IBOutlet weak var tiltValue: UILabel!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set picker delegate and date source.
        picker.delegate = self
        picker.dataSource = self
        
        // Set range of x values to xSlider
        xSlider.minimumValue = Keyframe.parametersRange.min.x
        xSlider.maximumValue = Keyframe.parametersRange.max.x
        
        // Set range of pan values to panSlider
        panSlider.minimumValue = Keyframe.parametersRange.min.pan
        panSlider.maximumValue = Keyframe.parametersRange.max.pan
      
        // Set range of tilt values to tiltSlider
        tiltSlider.minimumValue = Keyframe.parametersRange.min.tilt
        tiltSlider.maximumValue = Keyframe.parametersRange.max.tilt
        
        // Set default values to picker and sliders
        if let keyframe = keyframe {
            if Timecode.fullFormat {
            picker.selectRow(keyframe.timecode.min, inComponent: 0, animated: true)
            picker.selectRow(keyframe.timecode.sec, inComponent: 1, animated: true)
            picker.selectRow(keyframe.timecode.frame, inComponent: 2, animated: true)
            } else {
                picker.selectRow(keyframe.timecode.totalFrames, inComponent: 0, animated: true)
            }

            xSlider.value = keyframe.parameters.x
            
            panSlider.value = keyframe.parameters.pan
            
            tiltSlider.value = keyframe.parameters.tilt
            
        } else {
            xSlider.value = Keyframe.parametersRange.max.x/2
            panSlider.value = Keyframe.parametersRange.max.pan/2
            tiltSlider.value = Keyframe.parametersRange.max.tilt/2
        }
        xValue.text = String(format: "%.0f",xSlider.value)
        panValue.text = String(format: "%.0f",panSlider.value)
        tiltValue.text = String(format: "%.0f",tiltSlider.value)
        
        xSlider.addTarget(self, action: #selector(xValueChanged), for: .valueChanged)
        panSlider.addTarget(self, action: #selector(panValueChanged), for: .valueChanged)
        tiltSlider.addTarget(self, action: #selector(tiltValueChanged), for: .valueChanged)
    }
    
    // MARK: - Navigation

    // Action for pressing cancel button
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Action for pressing save button.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        var timecode: Timecode
        
        // Prepare values for the keyframe to be sent.
        if Timecode.fullFormat {
            let min = picker!.selectedRow(inComponent: 0)
            let sec = picker!.selectedRow(inComponent: 1)
            let frame = picker!.selectedRow(inComponent: 2)
            timecode = Timecode(min: min, sec: sec, frame: frame)
        } else {
            timecode = Timecode(frames: picker!.selectedRow(inComponent: 0))
        }
        
        let x = xSlider!.value.rounded()
        let pan = panSlider!.value.rounded()
        let tilt = tiltSlider!.value.rounded()
        
        // Set the keyframe to be sent after unwind
        keyframe = Keyframe(timecode: timecode, parameters: Parameters(x:x, pan: pan, tilt: tilt))
        
    }
    
    // MARK: - UIPickerDelegate and UIPickerDataSource.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if Timecode.fullFormat {
            return 3
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if Timecode.fullFormat{
            switch component {
            case 0:
                return 60
            case 1:
                return 60
            case 2:
                return Timecode.FPS
            default:
                return 0
            }
        } else {
            return 60*60*Timecode.FPS
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row);
    }
    
    @objc func xValueChanged(){
        xValue.text = String(format: "%.0f",xSlider.value)
    }
    @objc func panValueChanged(){
        panValue.text = String(format: "%.0f",panSlider.value)
    }
    @objc func tiltValueChanged(){
        tiltValue.text = String(format: "%.0f",tiltSlider.value)
    }
}
