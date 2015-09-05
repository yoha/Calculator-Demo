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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Stored Properties
    
    var isUserInTheMiddleOfTyping = false
    var operandStack = [Double]()
    
    // MARK: - Computed Properties
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(self.displayLabel.text!)!.doubleValue
        }
        set {
            self.displayLabel.text = "\(newValue)"
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
                if sender.currentTitle == "0" && self.displayLabel.text!.characters.contains(".") {
                    self.displayLabel.text! += sender.currentTitle!
                }
                else if self.displayLabel.text!.characters.contains(".") {
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
        }
    }
    
    @IBAction func appendFloatingPointButton(sender: UIButton) {
        if self.displayLabel.text!.characters.contains(".") { return }
        else {
            self.displayLabel.text!.append("." as Character)
            self.floatingPointButton.enabled = false
            self.isUserInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func clearDisplayButton(sender: UIButton) {
        self.displayLabel.text = "0"
        self.isUserInTheMiddleOfTyping = false
        self.floatingPointButton.enabled = true
    }
    
    @IBAction func enterButton() {
        self.operandStack.append(self.displayValue)
        print(self.operandStack)
        self.floatingPointButton.enabled = true
        self.isUserInTheMiddleOfTyping = false
    }
    
    @IBAction func performMathOperationButton(sender: UIButton) {
        if self.isUserInTheMiddleOfTyping { self.enterButton() }
        let mathOperator = sender.currentTitle!
        switch mathOperator {
            case "×": self.calculateOperands({ (op1: Double, op2: Double) -> Double in return op2 * op1 })
            case "÷": self.calculateOperands({ (op1, op2) in op2 / op1 })
            case "+": self.calculateOperands({ $1 + $0 })
            case "−": self.calculateOperands() { $1 - $0 }
            case "√": self.calculateOperands { sqrt($0) }
            default: break
        }
    }
    
    // MARK: - Local Methods
    
    func calculateOperands(operation: (op1: Double, op2: Double) -> Double) {
        guard self.operandStack.count >= 2 else { return }
        self.displayValue = operation(op1: self.operandStack.removeLast(), op2: self.operandStack.removeLast())
        self.enterButton()
    }
    
    @nonobjc // obj-c doesn't allow method overloading & this class inherits from UIViewController, which is an obj-c file despite writing it in swift.
    func calculateOperands(operation: (op1: Double) -> Double) {
        guard self.operandStack.count >= 1 else { return }
        self.displayValue = operation(op1: self.operandStack.removeLast())
        self.enterButton()
    }
}

