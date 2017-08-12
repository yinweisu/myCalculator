//
//  CalculatorBrain.swift
//  我的计算器
//
//  Created by Weisu Yin on 2017/6/23.
//  Copyright © 2017年 UCDavis. All rights reserved.
//

import Foundation

struct calculatorBrain {
    
    private var operation: String?
    
    private enum operationType{
        case constant(Double)
        case unaryOperation((Double) -> Double,(String) -> String)
        case binaryOperation((Double,Double) -> Double, (String, String) -> String)
        case random
        case equals
        case clear
    }
    
    private enum Elements{
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private var sequenceOfOperation = [Elements]()
    
    public var myDictionary =  [String: Double]()
    
    private var operations: Dictionary<String,operationType> =
        [
            "π": operationType.constant(Double.pi),
            "e": operationType.constant(M_E),
            "rand": operationType.random,
            "C": operationType.clear,
            "x²": operationType.unaryOperation({pow($0, 2)}, {"(" + $0 + ")²"}),
            "x³": operationType.unaryOperation({pow($0, 2)}, {"(" + $0 + ")³"}),
            "sin": operationType.unaryOperation({sin($0)}, {"sin("+$0+")"}),
            "cos": operationType.unaryOperation({cos($0)}, {"cos("+$0+")"}),
            "√": operationType.unaryOperation({sqrt($0)}, {"√("+$0+")"} ),
            "±": operationType.unaryOperation({-$0}, {"-("+$0+")"}),
            "%": operationType.unaryOperation({($0/100)}, {"("+$0+")%"}),
            "+": operationType.binaryOperation({$0+$1},{$0 + " + " + $1}),
            "−": operationType.binaryOperation({$0-$1},{$0 + " - " + $1}),
            "×": operationType.binaryOperation({$0*$1},{$0 + " × " + $1}),
            "÷": operationType.binaryOperation({$0/$1},{$0 + " ÷ " + $1}),
            "=": operationType.equals
    ]
    
    private struct PendingBinaryOperation {
        var operand1: (Double,String)
        var function: (Double,Double) -> Double
        var description: (String,String) -> String
        
        func perform(with operand2: (Double,String)) -> Double{
            return function(operand1.0,operand2.0)
        }
    }
    
    public mutating func undo(){
        if !sequenceOfOperation.isEmpty {
            sequenceOfOperation.removeLast()
        }
    }
    
    public mutating func setOperand(_ operand: String) {
        if let value = Double(operand){
            sequenceOfOperation.append(Elements.operand(value))
        }
    }
    
    public mutating func setOperand(variable named: String){
        sequenceOfOperation.append(Elements.variable(named))
    }
    
    public mutating func performOperation(using function: String){
        sequenceOfOperation.append(Elements.operation(function))
    }
    
    var result: Double?{
        return evaluate().result
    }
    
    var description: String?{
        return evaluate().description
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String){
        var accumulator: (Double, String)?
        var pendingBinaryOperation: PendingBinaryOperation?
        var resultIsPending = false
        var initialState = true
        
        func performBinaryOperation(){
            if pendingBinaryOperation != nil && accumulator != nil{
                accumulator = ((pendingBinaryOperation!.perform(with: accumulator!)), (" ( " + pendingBinaryOperation!.description(pendingBinaryOperation!.operand1.1, accumulator!.1) + " ) "))
            }
        }
        
        var result: Double?{
            if accumulator != nil{
                return accumulator!.0
            }
            return nil
        }
        
        var description: String? {
            get{
                if initialState{
                    return ""
                }
                if resultIsPending {
                    return pendingBinaryOperation!.description(pendingBinaryOperation!.operand1.1, accumulator?.1 ?? " ... ")
                } else {
                    if accumulator != nil{
                        return accumulator!.1 + " = "
                    }else{
                        return nil
                    }
                }
            }
        }
        
        for element in sequenceOfOperation{
            switch element{
            case .operation(let Function):
                if let operation = operations[Function]{
                    initialState = false
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, Function)
                        
                    case .unaryOperation(let function, let description):
                        if accumulator != nil{
                            accumulator = (function(accumulator!.0), description(accumulator!.1))
                        }
                    case .binaryOperation(let function, let description):
                        if accumulator != nil {
                            performBinaryOperation()
                            pendingBinaryOperation = PendingBinaryOperation(operand1: accumulator!,function: function, description: description)
                            resultIsPending = true
                            accumulator = nil
                        }
                    case .equals:
                        performBinaryOperation()
                        pendingBinaryOperation = nil
                        resultIsPending = false
                    case .clear:
                        accumulator = (0, "")
                        pendingBinaryOperation = nil
                        resultIsPending = false
                        initialState = true
                    case .random:
                        let randomNum = Double(arc4random()) / Double(UInt32.max)
                        accumulator = (randomNum, "rand()")
                    }
                }
                
            case .operand(let value):
                accumulator = (value, "\(value)")
                
            case .variable(let variable):
                if let value = variables?[variable]{
                    accumulator = (value, variable)
                }else {
                    accumulator = (0, variable)
                }
            }
            
        }
        return(result, resultIsPending, description ?? "")
    }
}
