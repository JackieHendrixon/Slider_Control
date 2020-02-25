//
//  KeyframesViewController.swift
//  Slider Control
//
//  Created by Franciszek Baron on 30/01/2020.
//  Copyright © 2020 Franciszek Baron. All rights reserved.
//

import UIKit

// ViewController responsible for managing keyframes
class KeyframesViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var timecode: TimecodeLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectionIndicator: Indicator!
    @IBOutlet weak var onlineIndicator: Indicator!
    @IBOutlet weak var onlineIndicatorLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registering delegation
        tableView.delegate = self
        tableView.dataSource = self
        SliderController.instance.delegates.append(self)
        GlobalTimecode.delegates.append(self)
        
        
        tableView.backgroundColor = .clear
        Sequence.instance.sort()
        
        updateProgressView()
        updateIndicators()
        updateTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: .didUpdateSequence, object: nil)
    }

    
    @objc func updateTableView(){
        tableView.reloadData()
    }
    
    // Updates the indicator state
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddKeyframe":
            guard let navigationController = segue.destination as? UINavigationController, let _ = navigationController.topViewController as? ModifyKeyframeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            navigationController.navigationBar.topItem?.title = "Add Keyframe"
    
        case "EditKeyframe":
            guard let navigationController = segue.destination as? UINavigationController, let modifyKeyframeViewController = navigationController.topViewController as? ModifyKeyframeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            navigationController.navigationBar.topItem?.title = "Edit Keyframe"
            
            guard let selectedKeyframeCell = sender as? KeyframesTableViewCell else {
                fatalError("Unexpected sender: \(sender!)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedKeyframeCell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            let selectedKeyframe = Sequence.instance.keyframes?[indexPath.row]
            modifyKeyframeViewController.keyframe = selectedKeyframe
            modifyKeyframeViewController.indexPath = indexPath
       
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    // Unwind from ModifyKeyframeViewController and refresh the data in sequence array and keyframesTableView
    @IBAction func unwindToKeyframeList(sender: UIStoryboardSegue){
        
        if let sourceViewController = sender.source as? ModifyKeyframeViewController, let keyframe = sourceViewController.keyframe {
 
            // Choose beetwen editing or adding new
            if let selectedIndexPath = sourceViewController.indexPath {
                Sequence.instance.keyframes?[selectedIndexPath.row] = keyframe
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                
                if let oldKeyframe = Sequence.instance.keyframes?.first(where: {$0.timecode == keyframe.timecode}) {
                    let row = Sequence.instance.keyframes?.firstIndex(of: oldKeyframe)
                    Sequence.instance.keyframes?.remove(at: row!)
                    let indexPath = IndexPath(row: row!, section: 0)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                
                Sequence.instance.keyframes?.append(keyframe)
                
                Sequence.instance.sort()
                let row = Sequence.instance.keyframes?.firstIndex(of: keyframe)
                let newIndexPath = IndexPath(row: row!, section: 0)

                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    
}

// MARK: - TableViewDelegate

extension KeyframesViewController: UITableViewDelegate, UITableViewDataSource  {
    
    // Returns how many rows a tableView section should have.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = Sequence.instance.keyframes?.count {
            return count
        } else {
            return 0
        }
    }
    
    // Returns a specific cell for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! KeyframesTableViewCell
        
        if let keyframe = Sequence.instance.keyframes?[indexPath.row] {
            cell.keyframe = keyframe
        }
        return cell
    }
    
    // Enables edition for a row.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Action for pressing delete button in a selected cell.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Sequence.instance.keyframes?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension KeyframesViewController: SliderControllerDelegate{
    func didConnect() {
        connectionIndicator.isOn = true
    }
    
    func didDisconnect() {
        connectionIndicator.isOn = false
    }
    
    func didCalibrate() {
        
    }
}

extension KeyframesViewController: GlobalTimecodeDelegate {
    func didUpdateGlobalTimecode() {
        updateProgressView()
    }
    
    
}
