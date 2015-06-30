//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by admin on 6/19/15.
//  Copyright (c) 2015 appsincaps. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    let bricksInRow = [5, 8, 12]

    @IBOutlet weak var numberOfBricksOutlet: UISegmentedControl!
    @IBAction func numberOfBricksControl(sender: UISegmentedControl) {
        let selection = sender.selectedSegmentIndex
        BreakoutSettings.numberOfBricksInRow = bricksInRow[selection]
        BreakoutSettings.updateStatus = true
    }
    
    @IBOutlet weak var numberOfRowsControl: UITextField! {
        didSet {
            numberOfRowsControl.delegate = self
            numberOfRowsControl.text = "\(BreakoutSettings.numberOfRows)"
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == numberOfRowsControl {
            if let number = NSNumberFormatter().numberFromString(numberOfRowsControl.text) {
                let rows = number.integerValue
                if rows > 0 {
                    BreakoutSettings.numberOfRows = rows
                    BreakoutSettings.updateStatus = true
                }
            }
        } else {
            
        }
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var rowStepperOutlet: UIStepper!
    @IBAction func rowStepper(sender: UIStepper) {
        BreakoutSettings.numberOfRows = Int(sender.value)
        numberOfRowsControl.text = "\(BreakoutSettings.numberOfRows)"
        BreakoutSettings.updateStatus = true
    }

    @IBOutlet weak var rowHeightLabel: UILabel!
    @IBAction func brickHeight(sender: UISlider) {
        BreakoutSettings.rowHeight = CGFloat(sender.value)
        BreakoutSettings.updateStatus = true
        rowHeightLabel.text = "\(Int(BreakoutSettings.rowHeight))"
    }
    @IBOutlet weak var rowHeightOutlet: UISlider!
    
    @IBAction func specialBrickSwitch(sender: UISwitch) {
        BreakoutSettings.specialBricks = sender.on
    }
    
    @IBOutlet weak var paddleSizeLabel: UITextField! {
        didSet {
            paddleSizeLabel.delegate = self
        }
    }
    @IBAction func paddleSizeSlider(sender: UISlider) {
        let width = CGFloat(sender.value * 200)
        let height = width / 4
        let percent = sender.value * 100
        BreakoutSettings.paddleWidth = width
        BreakoutSettings.paddleHeight = height
        paddleSizeLabel.text = "\(Int(percent))%"
        BreakoutSettings.updateStatus = true
    }
    @IBOutlet weak var paddleSizeOutlet: UISlider!
    
    @IBOutlet weak var paddleGravityOutlet: UISwitch!
    @IBAction func paddleGravity(sender: UISwitch) {
        BreakoutSettings.paddleGravity = sender.on
    }
    
    @IBOutlet weak var ballSizeLabel: UILabel!
    @IBAction func ballSizeStepper(sender: UIStepper) {
        BreakoutSettings.ballSize = CGFloat(sender.value)
        ballSizeLabel.text = "\(Int(BreakoutSettings.ballSize))"
        BreakoutSettings.updateStatus = true
    }
    @IBOutlet weak var ballSizeOutlet: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let array = bricksInRow as NSArray
        let value = array.indexOfObject(BreakoutSettings.numberOfBricksInRow)
        numberOfBricksOutlet.selectedSegmentIndex = value
        rowStepperOutlet.value = Double(BreakoutSettings.numberOfRows)
        numberOfRowsControl.text = "\(BreakoutSettings.numberOfRows)"
        rowHeightLabel.text = "\(Int(BreakoutSettings.rowHeight))"
        rowHeightOutlet.value = Float(BreakoutSettings.rowHeight)
        let width = BreakoutSettings.paddleWidth / 200
        paddleSizeOutlet.value = Float(width)
        paddleSizeLabel.text = "\(Int(width * 100))%"
        paddleGravityOutlet.on = BreakoutSettings.paddleGravity
        ballSizeLabel.text = "\(Int(BreakoutSettings.ballSize))"
        ballSizeOutlet.value = Double(BreakoutSettings.ballSize)
    }

}
