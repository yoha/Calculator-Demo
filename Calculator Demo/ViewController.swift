//
//  ViewController.swift
//  Calculator Demo
//
//  Created by Yohannes Wijaya on 9/4/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//
// to fix: the pie operation for the history label

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapGestureToNotifyDeepCleanOnce = UITapGestureRecognizer(target: self, action: "alertAboutDeepCleanOnce")
        self.clearButton.addGestureRecognizer(tapGestureToNotifyDeepCleanOnce)
        
        let longGestureToDeepCleanDisplayAndOpsStack = UILongPressGestureRecognizer(target: self, action: "deepCleanDisplayAndOpsStack:")
        longGestureToDeepCleanDisplayAndOpsStack.minimumPressDuration = 1.0
        self.clearButton.addGestureRecognizer(longGestureToDeepCleanDisplayAndOpsStack)
        
        self.floatingPointButton.enabled = false
        
        self.customNumberFormatter = NSNumberFormatter()
        self.customNumberFormatter.maximumSignificantDigits = 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Stored Properties
    
    var calculatorModel = CalculatorModel()
    
    var isUserInTheMiddleOfTyping = false
    
    var tapGestureToNotifyDeepCleanOnce: UITapGestureRecognizer!
    
    var customNumberFormatter: NSNumberFormatter!
    
    var calculationHistory = [String]()
    
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
            self.calculationHistory.append(self.displayLabel.text!)
            self.isUserInTheMiddleOfTyping = false
        }
    }

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var floatingPointButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var displayHistoryLabel: UILabel!
    
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
        self.clearDisplay()
    }
    
    @IBAction func deleteButton(sender: UIButton) {
        guard self.displayLabel.text!.characters.count > 1 else {
            self.displayValue = nil
            self.isUserInTheMiddleOfTyping = false
            return
        }
        self.displayLabel.text = String(self.displayLabel.text!.characters.dropLast())
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
            self.showPastCalculations(sender)
        }
        
    }
    
    // MARK: - Local Methods
    
    func alertAboutDeepCleanOnce() {
        let alertController = UIAlertController(title: "Tip:", message: "Tap & hold C to erase display & memory.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "I got it", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true) { [unowned self] () -> Void in
            self.clearButton.removeGestureRecognizer(self.tapGestureToNotifyDeepCleanOnce)
        }
    }
    
    func clearDisplay() {
        self.floatingPointButton.enabled = false
        self.displayValue = nil
        self.displayHistoryLabel.text = ""
        self.isUserInTheMiddleOfTyping = false
    }
    
    func deepCleanDisplayAndOpsStack(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == UIGestureRecognizerState.Began {
            let alertController = UIAlertController(title: "Erase display & memory?", message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Erase!", style: .Default, handler: { [unowned self] (alertAction) -> Void in
                self.calculatorModel.eraseOpsStack()
                self.clearDisplay()
            }))
            alertController.addAction(UIAlertAction(title: "Don't erase!", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func inversePolarity(sender: UIButton) {
        guard self.displayValue != 0 else { return }
        self.displayValue! -= self.displayValue! * 2
    }
    
    func showPastCalculations(mathOperatorButton: UIButton) {
        print(self.calculationHistory)
        guard self.calculationHistory.count > 0 else { return }
        let index = self.calculationHistory.count

        switch mathOperatorButton.currentTitle! {
            case "+", "−", "×", "÷":
                guard index >= 3 else { break }
                self.displayHistoryLabel.text! += self.calculationHistory[index - 3] + mathOperatorButton.currentTitle! + self.calculationHistory[index - 2] + "=" + "\(self.customNumberFormatter.stringFromNumber(self.displayValue!)!), "
            case "sin", "cos", "tan", "√":
                guard index >= 2 else { break }
                self.displayHistoryLabel.text! += mathOperatorButton.currentTitle! + self.calculationHistory[index - 2] + "=" + "\(self.customNumberFormatter.stringFromNumber(self.displayValue!)!), "
            case "π":
                guard index > 1 else {
                    self.displayHistoryLabel.text! += mathOperatorButton.currentTitle!
                    break
                }
                self.displayHistoryLabel.text! += mathOperatorButton.currentTitle! + "x" + self.calculationHistory[index - 2] + "=" + "\(self.customNumberFormatter.stringFromNumber(self.displayValue!)!), "
            default: break
        }
        self.calculationHistory = []
    }
    
}

