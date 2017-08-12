//
//  ViewController.swift
//  我的计算器
//
//  Created by Weisu Yin on 2017/6/23.
//  Copyright © 2017年 UCDavis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var userIsTypingNumber = false
    private var isFloatingNumber = false
    
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var sequenceOfOperands: UILabel!
    
    @IBOutlet weak var variableDisplay: UILabel!
    
    @IBAction func displayTheNumber(_ sender: UIButton) {
        let numberTyped = sender.currentTitle
        if userIsTypingNumber {
            if numberTyped == "." && !isFloatingNumber{
                display.text = display.text! + numberTyped!
                isFloatingNumber = true
            } else if numberTyped != "." {
                display.text = display.text! + numberTyped!
            }
        } else {
            if numberTyped != "."{
                display.text = numberTyped
                userIsTypingNumber = true
            }
        }
    }
    
    private func formatResult(_ rawResult: Double) -> String{
        let tempResult = rawResult * pow(10, 6)
        if floor(rawResult) == rawResult{
            return String(format:"%.0f",rawResult)
        }else if floor(tempResult) != tempResult{
            return String(format:"%.6f",rawResult)
        }else {
            return String(rawResult)
        }
    }
    
    private var calcBrain: calculatorBrain = calculatorBrain()
    
    @IBAction func setVariable(_ sender: UIButton) {
        if display.text != nil{
            calcBrain.myDictionary["M"] = Double(display.text!)
            let variableRawValue = calcBrain.myDictionary["M"]!
            let variableValue = formatResult(variableRawValue)
            variableDisplay.text = "M: \(variableValue)"
            userIsTypingNumber = false
            let solution = calcBrain.evaluate(using: calcBrain.myDictionary)
            if solution.result != nil{
                let result = formatResult(solution.result!)
                display.text = result
            }
        }
    }
    
    
    @IBAction func getVariable(_ sender: UIButton) {
        userIsTypingNumber = false
        calcBrain.setOperand(variable: "M")
        if calcBrain.myDictionary["M"] != nil{
            let variableValue = calcBrain.myDictionary["M"]!
            let result = formatResult(variableValue)
            variableDisplay.text = "M: \(result)"
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        calcBrain = calculatorBrain()
        display.text = "0"
        sequenceOfOperands.text = " "
        variableDisplay.text = " "
        userIsTypingNumber = false
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        if userIsTypingNumber, var text = display.text{
            let char = text.remove(at: text.index(before: text.endIndex))
            if char == "."{
                isFloatingNumber = false
            }
            if text.isEmpty{
                text = "0"
                userIsTypingNumber = false
            }
            display.text = text
        }else{
            calcBrain.undo()
            if let rawResult = calcBrain.evaluate().result{
                let result = formatResult(rawResult)
                display.text = result
                let description = calcBrain.evaluate().description
                sequenceOfOperands.text = description
            }
            
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTypingNumber{
            calcBrain.setOperand(display.text!)
            userIsTypingNumber = false
        }
        if let operationName = sender.currentTitle{
            calcBrain.performOperation(using: operationName)
        }
        if let rawResult = calcBrain.evaluate().result{
            let result = formatResult(rawResult)
            display.text = result
        }
        let description = calcBrain.evaluate().description
        sequenceOfOperands.text = description
        isFloatingNumber = false
    }
}

