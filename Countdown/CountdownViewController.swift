//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIPickerView!
    
    // MARK: - Properties
//     not loaded into memory unless called for. wont run unless you ask it to run.
//     an array of and array of strings
    lazy private var countdownPickerData: [[String]] = {
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
//        $0 small for loop. line "25" is an array of 60 int, converts them all into strings
//        create a continuous array of ranges from 0-60
        let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()
//    MARK: - Computed Property
    var dateformatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    private var duration: TimeInterval {
        let minuteString = countdownPicker.selectedRow(inComponent: 0)
        let secondString = countdownPicker.selectedRow(inComponent: 2)
        
        let minutes = Int(minuteString)
        let seconds = Int(secondString)
        
        let totalSeconds = TimeInterval(minutes * 60 + seconds)
        return totalSeconds
        
    }
    private let countdown = Countdown()
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownPicker.dataSource = self
        countdownPicker.delegate = self
        
        countdownPicker.selectRow(1, inComponent: 0, animated: false)
        countdownPicker.selectRow(30, inComponent: 2, animated: false)
        
        countdown.delegate = self
        countdown.duration = duration
        
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: timeLabel.font.pointSize, weight: .medium)
        updateViews()
        startButton.layer.cornerRadius = 8.0
        resetButton.layer.cornerRadius = 8.0
        updateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        countdown.start()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
        updateViews()
    }
    
    // MARK: - Private
    
    private func showAlert() {
        
//        Title: of message
//        message : body
//        ActionSheet : is a list of complex choice buttons that you can pick       from. it is presented modally
//        Alert. is a quick popup window thats gives a quick yes or no
        let alert = UIAlertController(title: "Timer Finished", message: "Your countdown is over.", preferredStyle: .alert)
//        handlers lets you give custom code. design an algorthim for when user presses ok.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present alert in an animated way
        present(alert, animated: true, completion: nil)
    }
    
    private func updateViews() {
//        if start button is enabled
        startButton.isEnabled = true
//        go through the diffrent countdown states
        switch countdown.state {
//            if the timer has started, it will
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
            startButton.isEnabled = false
        case .finished:
            timeLabel.text = string(from: 0)
        case .reset:
            timeLabel.text = string(from: countdown.duration)
        }
    }
    
    private func timerFinished(_ timer: Timer) {
        showAlert()
    }
//    Turns the date formattor into a string
    private func string(from duration: TimeInterval) -> String {
        let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateformatter.string(from: date)
    }
    }
extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()
    }
    
    func countdownDidFinish() {
        updateViews()
        showAlert()
    }
}

extension CountdownViewController: UIPickerViewDataSource {
//    number of component wheel
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return countdownPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        50
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//       selections in the wheel
        return countdownPickerData[component].count
    }
}

extension CountdownViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        the words that are presented in the wheel
        let timeValue = countdownPickerData[component][row]
        return timeValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdown.duration = duration
        updateViews()
    }
    }
