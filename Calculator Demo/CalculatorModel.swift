//
//  CalculatorModel.swift
//  Calculator Demo
//
//  Created by Yohannes Wijaya on 9/13/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import Foundation

class CalculatorModel {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case NullaryOperation(String, () -> Double)
        case UnaryOperation(String, (Double) -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            switch self {
                case .Operand(let operandValue): return "\(operandValue)"
                case .NullaryOperation(let mathOperatorSymbol, _): return mathOperatorSymbol
                case .UnaryOperation(let mathOperatorSymbol, _): return mathOperatorSymbol
                case .BinaryOperation(let mathOperatorSymbol, _): return mathOperatorSymbol
            }
        }
    }
    
    // MARK: - Stored Properties
    
    private var operandOrOperatorStack = [Op]()
    private var availableMathOperators = [String: Op]()
    
    // MARK: - Public Initializer
    
    init() {
        self.availableMathOperators["×"] = Op.BinaryOperation("×", { (operand1: Double, operand2: Double) -> Double in return operand2 * operand1 })
        self.availableMathOperators["÷"] = Op.BinaryOperation("÷", { (operand1, operand2) -> Double in operand2 / operand1 })
        self.availableMathOperators["+"] = Op.BinaryOperation("+", +)
        self.availableMathOperators["−"] = Op.BinaryOperation("−") {$1 - $0}
        self.availableMathOperators["√"] = Op.UnaryOperation("√", sqrt)
        self.availableMathOperators["sin"] = Op.UnaryOperation("sin", sin)
        self.availableMathOperators["cos"] = Op.UnaryOperation("cos", cos)
        self.availableMathOperators["tan"] = Op.UnaryOperation("tan", tan)
        self.availableMathOperators["π"] = Op.NullaryOperation("π") {M_PI}
    }
    
    // MARK: - Private Methods
    
    private func evaluateMembersOfTheStackRecursively(var opsInStack: [Op]) -> (evaluationResult: Double?, remainingOpsInStack: [Op]) {
        if opsInStack.count >= 1 {
            let opAtTheTopOfTheStack = opsInStack.removeLast()
            
            switch opAtTheTopOfTheStack {
            case .Operand(let anOperand):
                return (anOperand, opsInStack)
            case .NullaryOperation(_, let operation):
                return (operation(), opsInStack)
            case .UnaryOperation(_, let operation):
                let opToBeEvaluated = self.evaluateMembersOfTheStackRecursively(opsInStack)
                if let operand = opToBeEvaluated.evaluationResult {
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