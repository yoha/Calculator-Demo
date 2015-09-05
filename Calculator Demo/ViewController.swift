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
                else if sender.currentTitle! == "." {
                    self.floatingPointButton.enabled = false
                    self.displayLabel.text! += sender.currentTitle!
                }
                else if sender.currentTitle == "0" {
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
            if sender.currentTitle! == "." {
                self.displayLabel.text = "0."
                self.floatingPointButton.enabled = false
            }
            else {
                self.displayLabel.text = sender.currentTitle!
            }
            self.isUserInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func clearDisplayButton(sender: UIButton) {
        self.displayLabel.text = "0"
        self.isUserInTheMiddleOfTyping = false
        self.floatingPointButton.enabled = true
    }
    
}

