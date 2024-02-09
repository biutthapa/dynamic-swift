//
//  Core.swift
//  
//
//  Created by Biut Raj Thapa on 06/02/2024.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

enum ArithmeticOperation {
    case add, subtract, multiply, divide
}

fileprivate func compute(_ args: [Expr], op: ArithmeticOperation) throws -> Expr {
    guard !args.isEmpty else {
        throw EvalError.wrongNumberOfArgument(inOperation: "arithmatic computation", expected: "atleast one", found: "\(args.count)")
    }
    
    let numbers = try args.map { expr -> Number in
        switch expr {
        case .number(let value):
            return value
        default:
            throw EvalError.invalidArgument(argument: "non numberic", inOperation: "arithematic operation")
        }
    }
    
    let initialNumber: Number = {
        switch op {
        case .add:
            return 0
        case .multiply:
            return 1
        default:
            return numbers.first ?? 0
        }
    }()
    
    let operation: (Number, Number) throws -> Number = { acc, next in
        switch op {
        case .add:
            return acc + next
        case .subtract:
            return acc - next
        case .multiply:
            return acc * next
        case .divide:
            guard next != 0 else {
                throw MathError.divisionByZero(inOperation: "arithematic operation")
            }
            return acc / next
        }
    }

    let result: Number
    do {
        result = try numbers.reduce(initialNumber, operation)
    } catch {
        result = 0
    }
    return .number(result)
}


public let coreNS: [String: Lambda] = [
    "+": { args in try compute(args, op: .add) },
    "-": { args in try compute(args, op: .subtract) },
    "*": { args in try compute(args, op: .multiply) },
    "/": { args in try compute(args, op: .divide) },
//    "prn": { args in
//        prnStr(args.first(), readably: true)
//    }
]


