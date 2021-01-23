//
//  ChangeTimecodeViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import UIKit

class ChangeTimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {

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
        picker.selectRow(Int(CurrentTimecode.timecodeInterval)-1, inComponent: 0, animated: true)
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
        
   
        CurrentTimecode.timecodeInterval = Double(picker!.selectedRow(inComponent: 0)+1)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerDelegate and UIPickerDataSource.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       
            return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

            return 1000
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row+1);
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        return touch.view == gestureRecognizer.view
    }
}
