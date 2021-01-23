//
//  ConnectionViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class ConnectionViewController: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var calibrateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        
        view.layer.shadowOpacity = 0.20
        view.layer.shadowRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        
        SliderController.instance.delegates.append(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(SliderController.instance.slider.isConnected)
        if !SliderController.instance.slider.isConnected {
            
           connectButton.setTitle("Connect", for: .normal)
        } else {
            
            connectButton.setTitle("Disconnect", for: .normal)
        }
    }

    private func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.handleTapGesture(_:)))
        self.view.addGestureRecognizer(tap)
        tap.delegate = self
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func handleTapGesture(_ gestureRecognizer : UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
 
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func connectAction(_ sender: UIButton) {
        if !SliderController.instance.slider.isConnected {
            SliderController.instance.startLookingForConnection()
            
        } else {
            SliderController.instance.disconnect()
        }
    }
    
    @IBAction func calibrateAction(_ sender: UIButton) {
         SliderController.instance.getCalibration()
    }
}

extension ConnectionViewController: SliderControllerDelegate{
    func didConnect() {
        connectButton.setTitle("Disconnect", for: .normal)
        calibrateButton.isEnabled = true
    }
    
    func didDisconnect() {
        connectButton.setTitle("Connect", for: .normal)
    }
    
    func didCalibrate() {
        calibrateButton.isEnabled = false
    }
}

extension ConnectionViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        return touch.view == gestureRecognizer.view
    }
}
