//
//  ChangeTimecodeViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import UIKit

class ChangeTimecodeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        backgroundView.layer.shadowOpacity = 0.15
        backgroundView.layer.shadowRadius = 20
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        
        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Timecode.fullFormat {
            picker.selectRow(GlobalTimecode.current.min, inComponent: 0, animated: true)
            picker.selectRow(GlobalTimecode.current.sec, inComponent: 1, animated: true)
            picker.selectRow(GlobalTimecode.current.frame, inComponent: 2, animated: true)
        } else {
            picker.selectRow(GlobalTimecode.current.totalFrames, inComponent: 0, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    private func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.handleTapGesture(_:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func handleTapGesture(_ gestureRecognizer : UITapGestureRecognizer) {
        
        var timecode:Timecode
        if Timecode.fullFormat {
            let min = picker!.selectedRow(inComponent: 0)
            let sec = picker!.selectedRow(inComponent: 1)
            let frame = picker!.selectedRow(inComponent: 2)
            timecode = Timecode(min: min, sec: sec, frame: frame)
        } else {
            timecode = Timecode(frames: picker!.selectedRow(inComponent: 0))
        }
        GlobalTimecode.current = timecode
        
        dismiss(animated: true, completion: nil)
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
        if Timecode.fullFormat {
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
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        return touch.view == gestureRecognizer.view
    }
}
