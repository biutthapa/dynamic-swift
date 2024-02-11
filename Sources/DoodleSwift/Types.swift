//
//  Types.swift
//
//
//  Created by Biut Raj Thapa on 29/12/2023.
//

import Foundation

public typealias Lambda = ([Expr]) throws -> Expr
public typealias Number = Double

public enum ExprKey: Hashable {
    case symbol(String)
    case keyword(String)
    case number(Number)
    case boolean(Bool)
    case string(String)
    case list([Expr])
    case array([Expr])
    // let mixedArray = [1, "two", 3.0, (name: "Jane Doe", age: 30)]
//    indirect case pair(ExprKey, Expr)
    case map([ExprKey: Expr])
    // this the hashmap that looks like tuple but works like map in clojure.
    // let person = (name: "Jane Doe", age: 30, languages: ["English", "French"])
    case `nil`
}

public enum Expr {
    case symbol(String)
    case keyword(String)
    case number(Number)
    case `nil`
    case boolean(Bool)
    case string(String)
    case identifier(String)
//    indirect case pair(ExprKey, Expr)
    indirect case list([Expr])
    indirect case array([Expr])
    // let mixedArray = [1, "two", 3.0, (name: "Jane Doe", age: 30)]
    indirect case map([ExprKey: Expr])
    // this the hashmap that looks like tuple but works like map in clojure.
    // let person = (name: "Jane Doe", age: 30, languages: ["English", "French"])
    indirect case lambda(Lambda)
}



public enum DataError: Error {
    case unequalKeyValueCount(String)
}

public enum ParserError: Error {
    case invalidInput(String)
    case generalError(String)
    case unexpectedEndOfInput
    case unbalancedParentheses
    case invalidMapKey
    case invalidSyntax(String)
}

public enum EnvError: Error {
    case symbolNotFound(String)
    case symbolNotFound(symbol: String, available: [String])
}

public enum EvalError: Error {
    case wrongNumberOfArgument(inOperation: String, expected: String, found: String)
    case invalidArgument(argument: String, inOperation: String)
    case invalidPredicate(inOperation: String)
    case invalidSymbol(inOperation: String)
    case invalidName(inOperation: String)
    case generalError(String)
}

public enum MathError: Error {
    case divisionByZero(inOperation: String)
}
