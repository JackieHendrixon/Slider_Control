//
//  SimulationViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//


import UIKit

class SimulationViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var connectionIndicator: Indicator!
    @IBOutlet weak var onlineIndicator: Indicator!
    @IBOutlet weak var onlineIndicatorLabel: UILabel!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var leftAnimationView: AnimationView!
    @IBOutlet weak var rightAnimationView: AnimationView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var leftJoystick: Joystick!
    @IBOutlet weak var leftJoystickXConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightJoystick: Joystick!
    @IBOutlet weak var rightJoystickXConstraint: NSLayoutConstraint!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var sequenceNavigationButtons: UIStackView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var infoView: UIView!
    // MARK: - Init
    
    @IBOutlet weak var orangeBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var infoViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registering delegation
        SliderController.instance.delegates.append(self)
        
        
        // Setting animation view
        rightAnimationView.withRail = false
        
        // Setting joysticks
        leftJoystick.delegate = SliderController.instance
        leftJoystick.accessibilityIdentifier = "leftJoystick"
        rightJoystick.delegate = SliderController.instance
        rightJoystick.accessibilityIdentifier = "rightJoystick"
        
        setupInfoView()
        
        updateLayout()
        updateProgressView()
        updateAnimationViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSwitchMode), name: .didSwitchMode , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressView), name: .didUpdateCurrentTimecode, object: nil)
        

    }
    
    @IBAction func previousAction(_ sender: UIButton) {
        CurrentTimecode.previousFrame()
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        CurrentTimecode.nextFrame()
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        if !CurrentTimecode.isRunning {
            CurrentTimecode.run()
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        } else {
            CurrentTimecode.pause()
            playButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    @IBAction func stop(_ sender: UIButton) {
        CurrentTimecode.stop()
        playButton.setImage(UIImage(named: "Play"), for: .normal)
        
    }
    
    @IBAction func onlineAction(_ sender: Any) {
        let slider = SliderController.instance.slider
        if slider.isOnline {
            slider.isOnline = false
            onlineIndicator.isOn = false
        } else {
            if slider.isConnected {
                slider.isOnline = true
                onlineIndicator.isOn = true
                SliderController.instance.moveTo(position: Sequence.instance.calculateParameters(for: CurrentTimecode.current))
            }
        }
    }
    
    @IBAction func modeChangeAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            SliderController.instance.slider.mode = .live
            liveModeLayout()
        } else {
            SliderController.instance.slider.mode = .sequence
            sequenceModeLayout()
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        let slider = SliderController.instance.slider
        if slider.isConnected && slider.mode == .live {
            let position = slider.currentPosition
            let keyframe = Keyframe(timecode: CurrentTimecode.current, parameters: position)
            
            if let oldKeyframe = Sequence.instance.keyframes?.first(where: {$0.timecode == keyframe.timecode}) {
                let row = Sequence.instance.keyframes?.firstIndex(of: oldKeyframe)
                Sequence.instance.keyframes?.remove(at: row!)
            }
            Sequence.instance.keyframes?.append(keyframe)
            Sequence.instance.sort()
        }
    }
    
    @objc private func updateProgressView(){
        if let lastFrame = Sequence.instance.keyframes?.last?.timecode.totalFrames{
            progressView.progress = Float( CurrentTimecode.current.totalFrames) / Float( lastFrame)
        }
    }
    
    @objc private func updateAnimationViews() {
        rightAnimationView.update()
        leftAnimationView.update()
    }
    
    @objc func didSwitchMode(){
        if SliderController.instance.slider.mode == .live {
            if modeControl.selectedSegmentIndex != 0 {
                modeControl.selectedSegmentIndex = 0
                liveModeLayout()
            }
            
        } else {
            if modeControl.selectedSegmentIndex != 1 {
                modeControl.selectedSegmentIndex = 1
                sequenceModeLayout()
            }
        }
        updateAnimationViews()
    }
    
    private func liveModeLayout(){
        self.leftJoystick.isHidden = false
        self.rightJoystick.isHidden = false
        self.modeControl.isUserInteractionEnabled = false
        self.addButton.isEnabled = true
        self.orangeBarBottomConstraint.constant += 60
        self.infoViewBottomConstraint.constant -= 70
        UIView.animate(withDuration: 1.0, delay:0, options: [.curveEaseOut], animations: {
            self.leftJoystickXConstraint.constant += self.view.layer.frame.width
            self.rightJoystickXConstraint.constant -= self.view.layer.frame.width
            self.view.layoutIfNeeded()
            self.sequenceNavigationButtons.layer.opacity = 0
            self.onlineIndicator.layer.opacity = 0
            self.onlineIndicatorLabel.layer.opacity = 0
            }, completion: { (_) in
                self.sequenceNavigationButtons.isHidden = true
                self.onlineIndicator.isHidden = true
                self.onlineIndicatorLabel.isHidden = true
                self.modeControl.isUserInteractionEnabled = true
                })
    }
    
    private func sequenceModeLayout() {
        self.sequenceNavigationButtons.isHidden = false
        self.onlineIndicator.isHidden = false
        self.onlineIndicatorLabel.isHidden = false
        self.modeControl.isUserInteractionEnabled = false
        self.addButton.isEnabled = false
        self.orangeBarBottomConstraint.constant -= 60
        self.infoViewBottomConstraint.constant += 70
        UIView.animate(withDuration: 1.0, delay:0.0, options: [.curveEaseOut], animations:  {
            
            
            self.sequenceNavigationButtons.layer.opacity = 1
            self.onlineIndicator.layer.opacity = self.onlineIndicator.defaultOpacity
            self.onlineIndicatorLabel.layer.opacity = 1
        }, completion: { (_) in
            
        })
        UIView.animate(withDuration: 1.5, delay:0.3, options: [.curveEaseOut], animations:  {
            self.leftJoystickXConstraint.constant -= self.view.layer.frame.width
            self.rightJoystickXConstraint.constant += self.view.layer.frame.width
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.leftJoystick.isHidden = true
            self.rightJoystick.isHidden = true
            self.modeControl.isUserInteractionEnabled = true
        })
    }
    
    private func updateLayout() {
        if SliderController.instance.slider.mode == .live {
            self.sequenceNavigationButtons.isHidden = true
            self.sequenceNavigationButtons.layer.opacity = 0
            self.onlineIndicator.isHidden = true
            self.onlineIndicator.layer.opacity = 0
            self.onlineIndicatorLabel.isHidden = true
            self.onlineIndicatorLabel.layer.opacity = 0
        } else {
            self.sequenceNavigationButtons.isHidden = false
            self.sequenceNavigationButtons.layer.opacity = 1
            self.onlineIndicator.isHidden = false
            self.onlineIndicator.layer.opacity = self.onlineIndicator.defaultOpacity
            self.onlineIndicatorLabel.isHidden = false
            self.onlineIndicatorLabel.layer.opacity = 1
        }
    }
    
    private func setupInfoView(){
        infoView.layer.cornerRadius = 20
    }
    
}

extension SimulationViewController: SliderControllerDelegate{
    func didConnect() {
        connectionIndicator.isOn = true
    }
    
    func didDisconnect() {
        connectionIndicator.isOn = false
        onlineIndicator.isOn = false
    }
    
    func didCalibrate() {
    }
}



