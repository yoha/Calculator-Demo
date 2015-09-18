//
//  ViewController.swift
//  Calculator Demo
//
//  Created by Yohannes Wijaya on 9/4/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.floatingPointButton.enabled = false
        
        self.customNumberFormatter = NSNumberFormatter()
        self.customNumberFormatter.minimumFractionDigits = 0
        self.customNumberFormatter.maximumFractionDigits = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Stored Properties
    
    var isUserInTheMiddleOfTyping = false
    var calculatorModel = CalculatorModel()
    
    var customNumberFormatter: NSNumberFormatter!
    
    // MARK: - Computed Properties
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(self.displayLabel.text!)!.doubleValue ?? nil
        }
        set {
            guard newValue != nil else {
                self.displayLabel.text = "0"
                return
            }
            self.displayLabel.text = self.customNumberFormatter.stringFromNumber(NSNumber(double: newValue!))
            self.isUserInTheMiddleOfTyping = false
        }
    }

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var floatingPointButton: UIButton!
    
    // MARK: - IBAction Properties
    
    @IBAction func appendDigitButton(sender: UIButton) {
        if isUserInTheMiddleOfTyping {
            if self.displayLabel.text!.characters.first == "0" {
                if sender.currentTitle == "0" && self.displayLabel.text!.characters.contains(".") || self.displayLabel.text!.characters.contains("."){
                    self.displayLabel.text! += sender.currentTitle!
                }
                else if sender.currentTitle! == "0" {
                    return
                }
                else {
                    self.displayLabel.text!.removeAtIndex(self.displayLabel.text!.startIndex)
                    self.displayLabel.text! += sender.currentTitle!
                }
            }
            else {
                if self.displayLabel.text!.characters.contains(".") {
                    self.floatingPointButton.enabled = false
                }
                self.displayLabel.text! += sender.currentTitle!
            }
        }
        else {
            self.displayLabel.text = sender.currentTitle!
            self.isUserInTheMiddleOfTyping = true
            self.floatingPointButton.enabled = true
        }
    }
    
    @IBAction func appendFloatingPointButton(sender: UIButton) {
        self.displayLabel.text!.append("." as Character)
        self.floatingPointButton.enabled = false
    }
    
    @IBAction func clearDisplayButton(sender: UIButton) {
        self.displayValue = nil
        self.isUserInTheMiddleOfTyping = false
        self.floatingPointButton.enabled = false
    }
    
    @IBAction func enterButton() {
        self.floatingPointButton.enabled = false
        self.isUserInTheMiddleOfTyping = false
        if let evaluationResult = self.calculatorModel.pushOperand(self.displayValue!) {
            self.displayValue = evaluationResult
        }
    }
    
    @IBAction func performMathOperationButton(sender: UIButton) {
        if self.isUserInTheMiddleOfTyping { self.enterButton() }
        if let mathOperator = sender.currentTitle {
            if let evaluationResult = self.calculatorModel.pushOperator(mathOperator) {
                self.displayValue = evaluationResult
            }
        }
    }
}

