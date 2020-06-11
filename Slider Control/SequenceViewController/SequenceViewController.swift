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
    @IBOutlet weak var slidePlot: NewPlotView!
    @IBOutlet weak var tiltPlot: NewPlotView!
    @IBOutlet weak var panPlot: NewPlotView!
    @IBOutlet weak var xPlotLabel: UILabel!
    @IBOutlet weak var panPlotLabel: UILabel!
    @IBOutlet weak var tiltPlotLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var plotsViewModel: PlotsViewModel = {
        let plotsViewModel = PlotsViewModel(sequence: NewSequenceModel.testSequence())
        
        return plotsViewModel
    }()
    
    // MARK: - Views
    
//    private let timecodeLabel: TimecodeLabel = {
//        let label = UILabel(
//        
//        
//        return label
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registering self as the delegate
        SliderController.instance.delegates.append(self)
        plotsViewModel.delegate = self
        
        didViewModelUpdate()
        panPlot.delegate = self
        tiltPlot.delegate = self
        slidePlot.delegate = self
        
        rotatePlotLabels()
        updateProgressView()
        updateIndicators()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressView), name: .didUpdateCurrentTimecode, object: nil)
    }
    
    // MARK: - Actions

    @IBAction func previous(_ sender: UIButton) {
        CurrentTimecode.previousFrame()
    }
    @IBAction func next(_ sender: UIButton) {
        CurrentTimecode.nextFrame()
    }
    @IBAction func play(_ sender: UIButton) {
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
    
    
    private func updateIndicators() {
        connectionIndicator.isOn = SliderController.instance.slider.isConnected
        onlineIndicator.isOn = SliderController.instance.slider.isOnline
        onlineIndicator.isHidden = SliderController.instance.slider.mode == .live
        onlineIndicatorLabel.isHidden = SliderController.instance.slider.mode == .live
    }
    
    @objc private func updateProgressView() {
        if let lastFrame = Sequence.instance.keyframes?.last?.timecode.totalFrames{
            progressView.progress = Float( CurrentTimecode.current.totalFrames) / Float( lastFrame)
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

extension SequenceViewController: PlotsViewModelDelegate {
    func didViewModelUpdate() {
        plotsViewModel.configure(panPlot, ofType: .pan)
        plotsViewModel.configure(tiltPlot, ofType: .tilt)
        plotsViewModel.configure(slidePlot, ofType: .slide)
        
        panPlot.setNeedsDisplay()
        tiltPlot.setNeedsDisplay()
        slidePlot.setNeedsDisplay()
        
    }
}

extension SequenceViewController: PlotViewDelegate {
    func addedPoint(_ point: Point, for view: NewPlotView) {
        print("addedPoint: \(point)")
        var keyframes: Keyframes!
        switch view {
        case panPlot:
            keyframes = plotsViewModel.sequence.panKeyframes
        case tiltPlot:
            keyframes = plotsViewModel.sequence.tiltKeyframes
        case slidePlot:
            keyframes = plotsViewModel.sequence.slideKeyframes
        default:
            fatalError()
        }
        
        keyframes.insertValid(point: point)
        print(keyframes!)
        NotificationCenter.default.post(name: .didUpdateSequence, object: nil)
        
    }
    
    func deletedPoint(_ point: Point, for view: NewPlotView) {
        print("deletedPoint: \(point)")
        var keyframes: Keyframes!
        switch view {
        case panPlot:
            keyframes = plotsViewModel.sequence.panKeyframes
        case tiltPlot:
            keyframes = plotsViewModel.sequence.tiltKeyframes
        case slidePlot:
            keyframes = plotsViewModel.sequence.slideKeyframes
        default:
            fatalError()
        }
        
        keyframes.delete(point: point)
        print(keyframes!)
        NotificationCenter.default.post(name: .didUpdateSequence, object: nil)
    }
    
    func movedPoint(from oldPoint: Point, to newPoint: Point, for view: NewPlotView) {
        print("movedOldPoint: \(oldPoint) newPoint \(newPoint)")
        var keyframes: Keyframes!
        switch view {
        case panPlot:
            keyframes = plotsViewModel.sequence.panKeyframes
        case tiltPlot:
            keyframes = plotsViewModel.sequence.tiltKeyframes
        case slidePlot:
            keyframes = plotsViewModel.sequence.slideKeyframes
        default:
            fatalError()
        }
        
        keyframes.move(point: oldPoint, to: newPoint)
        
        NotificationCenter.default.post(name: .didUpdateSequence, object: nil)
    }
    
    func movedControlPoint(from oldPoint: Point, to newPoint: Point, parent: Point, secondPoint: Point?, for view: NewPlotView){
        var keyframes: Keyframes!
        switch view {
        case panPlot:
            keyframes = plotsViewModel.sequence.panKeyframes
        case tiltPlot:
            keyframes = plotsViewModel.sequence.tiltKeyframes
        case slidePlot:
            keyframes = plotsViewModel.sequence.slideKeyframes
        default:
            fatalError()
        }
        
        keyframes.moveControlPoint(old: oldPoint, new: newPoint, parent: parent, second: secondPoint)
        
        NotificationCenter.default.post(name: .didUpdateSequence, object: nil)
    }
}

