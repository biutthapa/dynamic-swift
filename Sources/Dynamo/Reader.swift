//
//  Reader.swift
//
//
//  Created by Biut Raj Thapa on 29/12/2023.
//

import Foundation

struct Reader {
    let tokens: [String]
    let position: Int

    init(tokens: [String], position: Int = 0) {
        self.tokens = tokens
        self.position = position
    }

    func peek() -> String? {
        guard position < tokens.count else { return nil }
        return tokens[position]
    }

    func next() -> Reader {
        return Reader(tokens: self.tokens, position: self.position + 1)
    }
}

func readBlock(_ reader: Reader) throws -> (Expr, Reader) {
    guard let token = reader.peek() else {
        throw ParserError.unexpectedEndOfInput
    }

    switch token {
    case "let", "func", "if", "for", "while":
        return try readStatement(reader)
    default:
        return try readExpression(reader)
    }
}

func readBlocks(_ reader: Reader) throws -> ([Expr], Reader) {
    var expressions = [Expr]()
    
    while let _ = reader.peek() {
        let (expr, _) = try readBlock(reader)
        expressions.append(expr)
    }
    
    return (expressions, reader)
}

func readStatement(_ reader: Reader) throws -> (Expr, Reader) {
    // Implementation for reading statements like let, func, if, for, while
    throw ParserError.invalidSyntax("Statements parsing not implemented yet.")
}

func readExpression(_ reader: Reader) throws -> (Expr, Reader) {
    // Implementation for reading expressions
    throw ParserError.invalidSyntax("Expressions parsing not implemented yet.")
}

func readAtom(_ reader: Reader) throws -> (Expr, Reader) {
    guard let token = reader.peek() else {
        throw ParserError.unexpectedEndOfInput
    }

    if let number = Double(token) {
        return (.number(number), reader.next())
    } else if token.first == ":" {
        let keyword = String(token.dropFirst())
        return (.keyword(keyword), reader.next())
    } else if token == "nil" {
        return (.nil, reader.next())
    } else if token == "true" {
        return (.boolean(true), reader.next())
    } else if token == "false" {
        return (.boolean(false), reader.next())
    } else if token.first == "\"" {
        return try readStringLiteral(token, reader: reader)
    } else {
        return (.symbol(token), reader.next())
    }
}

func readStringLiteral(_ token: String, reader: Reader) throws -> (Expr, Reader) {
    var processedString = ""
    var escapeNext = false
    for char in token.dropFirst().dropLast() {
        if escapeNext {
            switch char {
            case "\"": processedString += "\""
            case "n": processedString += "\n"
            case "\\": processedString += "\\"
            default: throw ParserError.invalidInput("Invalid escape sequence")
            }
            escapeNext = false
        } else if char == "\\" {
            escapeNext = true
        } else {
            processedString += String(char)
        }
    }
    if escapeNext {
        throw ParserError.invalidInput("Invalid string termination")
    }
    return (.string(processedString), reader.next())
}



func readSequence(_ reader: Reader, startDelimiter: String, endDelimiter: String) throws -> (Expr, Reader) {
    var reader = reader
    var items = [Expr]()

    while let token = reader.peek(), token != endDelimiter {
        let (expr, nextReader) = try readBlock(reader)
        items.append(expr)
        reader = nextReader
    }

    guard reader.peek() == endDelimiter else {
        throw ParserError.unbalancedParentheses
    }

    let expr: Expr = (startDelimiter == "(") ? .list(items) : .array(items)
    return (expr, reader.next())
}



func readHashMap(_ reader: Reader) throws -> (Expr, Reader) {
    var reader = reader
    var map = [ExprKey: Expr]()

    while let token = reader.peek(), token != "}" {
        // Parse the key
        let (keyExpr, nextReaderForKey) = try readBlock(reader)
        guard let mapKey = keyExpr.makeKey() else {
            throw ParserError.invalidMapKey
        }
        reader = nextReaderForKey

        // Parse the value
        let (valueExpr, nextReaderForValue) = try readBlock(reader)
        map[mapKey] = valueExpr
        reader = nextReaderForValue
    }

    guard reader.peek() == "}" else {
        throw ParserError.unbalancedParentheses
    }

    return (.map(map), reader.next())
}





public func readStr(_ input: String) -> [Expr] {
    let tokens = tokenizeString(input)
    let reader = Reader(tokens: tokens, position: 0)
    do {
        let (parsed, _) = try readBlocks(reader)
        return parsed
    } catch {
        print("Parsing error: \(error)")
        return []
    }
}
func tokenizeString(_ input: String) -> [String] {
    let patterns = [
        #""[^"\\]*(\\.[^"\\]*)*""#, // Corrected string literals pattern
        #"[\d]+(?:\.\d+)?(?:e[\+\-]?\d+)?"#, // Decimal & integer numbers
        #"\[|\]"#, // Array brackets
        #"\(|\)"#, // Parentheses for expressions or tuples
        #"\{|\}"#, // Curly braces for hashmaps (if needed)
        #"\w+"#, // Identifiers (variable names, function names)
        #"\s+"#, // Whitespace as separators
        #","#, // Comma as tuple or array separator
        #"true|false"# // Boolean literals
    ]
    let pattern = patterns.joined(separator: "|")
    
    var tokens = extractMatches(from: input, usingPattern: pattern)
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty && !$0.trimmingCharacters(in: .whitespaces).starts(with: ";") }
    
    return tokens
}
