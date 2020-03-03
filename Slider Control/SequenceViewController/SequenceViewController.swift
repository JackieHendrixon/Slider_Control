//
//  SequenceViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import UIKit

// Class responsible for the Sequence Scene

class SequenceViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var connectionIndicator: Indicator!
    @IBOutlet weak var onlineIndicator: Indicator!
    @IBOutlet weak var onlineIndicatorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var plot: PlotView!
    @IBOutlet weak var xPlotLabel: UILabel!
    @IBOutlet weak var panPlotLabel: UILabel!
    @IBOutlet weak var tiltPlotLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registering self as the delegate
        SliderController.instance.delegates.append(self)
        GlobalTimecode.delegates.append(self)
        
        rotatePlotLabels()
        updateProgressView()
        updateIndicators()
    }
    
    // MARK: - Actions

    @IBAction func previous(_ sender: UIButton) {
        GlobalTimecode.previousFrame()
    }
    @IBAction func next(_ sender: UIButton) {
        GlobalTimecode.nextFrame()
    }
    @IBAction func play(_ sender: UIButton) {
        if !GlobalTimecode.isRunning {
            GlobalTimecode.run()
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        } else {
            GlobalTimecode.pause()
            playButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    @IBAction func stop(_ sender: UIButton) {
        GlobalTimecode.stop()
        playButton.setImage(UIImage(named: "Play"), for: .normal)
    }
    
    
    private func updateIndicators() {
        connectionIndicator.isOn = SliderController.instance.slider.isConnected
        onlineIndicator.isOn = SliderController.instance.slider.isOnline
        onlineIndicator.isHidden = SliderController.instance.slider.mode == .live
        onlineIndicatorLabel.isHidden = SliderController.instance.slider.mode == .live
    }
    
    private func updateProgressView() {
        if let lastFrame = Sequence.instance.keyframes?.last?.timecode.totalFrames{
            progressView.progress = Float( GlobalTimecode.current.totalFrames) / Float( lastFrame)
        }
    }
    
    private func rotatePlotLabels() {
        xPlotLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        panPlotLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        tiltPlotLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
    }
}

extension SequenceViewController: SliderControllerDelegate{
    func didConnect() {
        connectionIndicator.isOn = true
    }
    
    func didDisconnect() {
        connectionIndicator.isOn = false
    }
    
    func didCalibrate() {    
    }
}

extension SequenceViewController: GlobalTimecodeDelegate {
    func didUpdateGlobalTimecode() {
        updateProgressView()
    }
}

