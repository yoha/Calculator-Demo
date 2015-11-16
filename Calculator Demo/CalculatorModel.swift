//
//  CalculatorModel.swift
//  Calculator Demo
//
//  Created by Yohannes Wijaya on 9/13/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//
// TODO: figure out how unaryOperation is able to process displayValue that isn't appended to the ops stack

import Foundation

class CalculatorModel {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, (Double) -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            switch self {
                case .Operand(let operandValue): return "\(operandValue)"
                case .UnaryOperation(let mathOperatorSymbol, _): return mathOperatorSymbol
                case .BinaryOperation(let mathOperatorSymbol, _): return mathOperatorSymbol
            }
        }
    }
    
    // MARK: - Stored Properties
    
    private var operandOrOperatorStack = [Op]()
    private var availableMathOperators = [String: Op]()
    
    // MARK: - Computed Properties
    
    /*** a Property List to be passed to NSUserDefaults if needed ***/
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            // option 1
            return self.operandOrOperatorStack.map { $0.description }
            // option 2
            /***
            var returnValue = Array<String>()
            for op in self.operandOrOperatorStack {
                returnValue.append(op.description)
            }
            return returnValue
            ***/
        }
        set {
            guard let arrayOfOps = newValue as? Array<String> else { return }
            var newOperandOrOperatorStack = Array<Op>()
            for eachOp in arrayOfOps {
                if let op = self.availableMathOperators[eachOp] {
                    newOperandOrOperatorStack.append(op)
                }
                else if let operand = NSNumberFormatter().numberFromString(eachOp)?.doubleValue {
                    newOperandOrOperatorStack.append(.Operand(operand))
                }
            }
            self.operandOrOperatorStack = newOperandOrOperatorStack
        }
    }
    
    // MARK: - Public Initializer
    
    init() {
        self.availableMathOperators["×"] = Op.BinaryOperation("×", { (operand1: Double, operand2: Double) -> Double in return operand2 * operand1
        })
        self.availableMathOperators["÷"] = Op.BinaryOperation("÷", { (operand1, operand2) -> Double in operand2 / operand1 })
        self.availableMathOperators["+"] = Op.BinaryOperation("+", +)
        self.availableMathOperators["−"] = Op.BinaryOperation("−") {$1 - $0}
        self.availableMathOperators["√"] = Op.UnaryOperation("√", { (operand: Double) -> Double in
//            print("operand1: \(operand)") // <---
            return sqrt(operand)
        })
        self.availableMathOperators["sin"] = Op.UnaryOperation("sin", { (operand) -> Double in
            sin(operand)
        })
        self.availableMathOperators["cos"] = Op.UnaryOperation("cos") { cos($0) }
        self.availableMathOperators["tan"] = Op.UnaryOperation("tan", tan)
    }
    
    // MARK: - Private Methods
    
    private func evaluateMembersOfTheStackRecursively(var opsInStack: [Op]) -> (evaluationResult: Double?, remainingOpsInStack: [Op]) {
        if opsInStack.count >= 1 {
            let opAtTheTopOfTheStack = opsInStack.removeLast()
            
            switch opAtTheTopOfTheStack {
            case .Operand(let anOperand):
//                print("anOperand: \(anOperand)") // <---
                return (anOperand, opsInStack)
            case .UnaryOperation(_, let operation):
                let opToBeEvaluated = self.evaluateMembersOfTheStackRecursively(opsInStack)
                if let operand = opToBeEvaluated.evaluationResult {
//                    print("operand2: \(operand)") // <---
                    return (operation(operand), opToBeEvaluated.remainingOpsInStack)
                }
            case .BinaryOperation(_, let operation):
                let op1ToBeEvaluated = self.evaluateMembersOfTheStackRecursively(opsInStack)
                if let operand1 = op1ToBeEvaluated.evaluationResult {
                    let op2ToBeEvaluated = self.evaluateMembersOfTheStackRecursively(op1ToBeEvaluated.remainingOpsInStack)
                    if let operand2 = op2ToBeEvaluated.evaluationResult {
                        return (operation(operand1, operand2), op2ToBeEvaluated.remainingOpsInStack)
                    }
                }
            }
        }
        return (nil, opsInStack)
    }
    
    
    // MARK: Public Methods
    
    func eraseOpsStack() {
        self.operandOrOperatorStack = []
        print(self.operandOrOperatorStack)
    }
    
    func performEvaluation() -> Double? {
        let (evaluationResult, remainingOpsInStack) = self.evaluateMembersOfTheStackRecursively(self.operandOrOperatorStack)
        print("\(self.operandOrOperatorStack) = \(evaluationResult) with \(remainingOpsInStack) remaining")
        return evaluationResult
    }
    
    func pushOperand(operand: Double) -> Double? {
        self.operandOrOperatorStack.append(Op.Operand(operand))
        return self.performEvaluation()
    }
    
    func pushOperator(mathSymbol: String) -> Double? {
        if let mathOperation = self.availableMathOperators[mathSymbol] {
            self.operandOrOperatorStack.append(mathOperation)
        }
        return self.performEvaluation()
    }
}