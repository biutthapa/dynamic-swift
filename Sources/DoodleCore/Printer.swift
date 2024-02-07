//
//  Printer.swift
//
//
//  Created by Biut Raj Thapa on 29/12/2023.
//

import Foundation

public func prnStr(_ expr: Expr) -> String {
    switch expr {
    case .symbol(let symbol):
        return symbol
    case .keyword(let keyword):
        return ":\(keyword)"
    case .number(let number):
        return String(number)
    case .boolean(let boolean):
        return boolean ? "true" : "false"
    case .string(let string):
        return "\"\(string)\""
    case .list(let list):
        let listContents = list.map(prnStr).joined(separator: " ")
        return "(\(listContents))"
    case .vector(let vector):
        let vectorContents = vector.map(prnStr).joined(separator: " ")
        return "[\(vectorContents)]"
    case .map(let mapPairs):
        let mapContents = mapPairs.map { (key, value) in prnStr(key.toExpr()) + " " + prnStr(value) }.joined(separator: " ")
        return "{\(mapContents)}"
    case .nil:
        return "nil"
    case .lambda:
        return "#<lambda>"

    }
}

