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
    "+": { try compute($0, op: .add) },
    "-": { try compute($0, op: .subtract) },
    "*": { try compute($0, op: .multiply) },
    "/": { try compute($0, op: .divide) },
    "prn": { print($0.map { prnStr($0, readably: true) }.joined(separator: " ")); return .nil},
    "list": { return .list($0) },
//    "list?": { return .boolean($0.count == 1 ? $0.first()!.isListP() : false) },
    "vector?": { if $0.count == 1 { return .boolean($0.first()!.isVectorP()) }
        else {throw EvalError.wrongNumberOfArgument(inOperation: "vector?",
                                                    expected: "1", found: "\($0.count)")}
    },
    "empty?": { if $0.count == 1 { return .boolean($0.first()!.isEmptyP()) }
        else { throw EvalError.wrongNumberOfArgument(inOperation: "empty?",
                                                     expected: "1", found: "\($0.count)") }
    },
    
    "count": { if $0.count == 1 { return .number(Number(try ($0.first()?.count())!)) }
        else { throw EvalError.wrongNumberOfArgument(inOperation: "count",
                                                     expected: "1", found: "\($0.count)") }
    },
        


    // TODO: quote
    // TODO: cons
    // TODO: first
    // TODO: rest
    // TODO: list
    // TODO: "=" for comparision
    // TODO: "=" as assignment operator
    // TODO: "keep" as in "keep these items from a sequence"
    // TODO: "map"
    
    
    
]


