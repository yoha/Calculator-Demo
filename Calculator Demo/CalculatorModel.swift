//
//  CalculatorModel.swift
//  Calculator Demo
//
//  Created by Yohannes Wijaya on 9/13/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import Foundation

class CalculatorModel {
    
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    // MARK: - Stored Properties
    
    private var operandOrOperatorStack = [Op]()
    private var availableMathOperators = [String: Op]()
    
    // MARK: - Public Initializer
    
    init() {
        self.availableMathOperators["×"] = Op.BinaryOperation("×", { (operand1: Double, operand2: Double) -> Double in return operand2 * operand1 })
        self.availableMathOperators["÷"] = Op.BinaryOperation("÷", { (operand1, operand2) -> Double in operand2 / operand1 })
        self.availableMathOperators["+"] = Op.BinaryOperation("+", +)
        self.availableMathOperators["−"] = Op.BinaryOperation("−") { $1 - $0 }
        self.availableMathOperators["√"] = Op.UnaryOperation("√", sqrt)
    }
    
    // MARK: - Private Methods
    
    private func evaluateMembersOfTheStackRecursively(var opsInStack: [Op]) -> (evaluationResult: Double?, remainingOpsInStack: [Op]) {
        if !self.operandOrOperatorStack.isEmpty {
            let opAtTheTopOfTheStack = opsInStack.removeLast()
            
            switch opAtTheTopOfTheStack {
            case .Operand(let anOperand):
                return (anOperand, opsInStack)
            case .UnaryOperation(_, let operation):
                let opToBeEvaluated = self.evaluateMembersOfTheStackRecursively(opsInStack)
                if let op = opToBeEvaluated.evaluationResult {
                    return (operation(op), opToBeEvaluated.remainingOpsInStack)
                }
            case .BinaryOperation(_, let operation):
                let op1ToBeEvaluated = self.evaluateMembersOfTheStackRecursively(opsInStack)
                if let op1 = op1ToBeEvaluated.evaluationResult {
                    let op2ToBeEvaluated = self.evaluateMembersOfTheStackRecursively(op1ToBeEvaluated.remainingOpsInStack)
                    if let op2 = op2ToBeEvaluated.evaluationResult {
                        return (operation(op1, op2), op2ToBeEvaluated.remainingOpsInStack)
                    }
                }
            }
        }
        return (nil, opsInStack)
    }
    
    
    // MARK: Public Methods
    
    func performEvaluation() -> Double? {
        let (evaluationResult, _) = self.evaluateMembersOfTheStackRecursively(self.operandOrOperatorStack)
        return evaluationResult
    }
    
    func pushOperand(operand: Double) -> Double? {
        operandOrOperatorStack.append(Op.Operand(operand))
        return self.performEvaluation()
    }
    
    func pushOperator(mathSymbol: String) -> Double? {
        if let mathOperator = self.availableMathOperators[mathSymbol] {
            self.operandOrOperatorStack.append(mathOperator)
        }
        return self.performEvaluation()
    }
}