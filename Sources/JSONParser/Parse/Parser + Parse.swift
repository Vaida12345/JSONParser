//
//  Parser + Parse.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation

@inline(__always)
func isJSONWhitespace(_ byte: UInt8) -> Bool {
    byte == 0x20 || byte == 0x09 || byte == 0x0A || byte == 0x0D
}

extension JSONParser {
    
    /// Parse the given `data`, assuming it is a top-level JSON dictionary.
    public init(data: Data) throws(ParseError) {
        let original = data
        let data = data.dropFirst(while: isJSONWhitespace)
                       .dropLast(while: isJSONWhitespace)
        guard !data.isEmpty else { throw ParseError(message: "Input data is empty", index: original.startIndex, data: original) }
        guard data.first == 123 else { throw ParseError(message: "Missing start bracket '{'", index: data.startIndex, data: original) }
        guard data.last == 125 else { throw ParseError(message: "Missing end bracket '}'", index: max(data.endIndex &- 1, data.startIndex), data: original) }
        
        var index = data.startIndex + 1
        
        // states
        enum State {
            case idle
            /// Currently scanning a quoted key; holds the start byte index of the key content.
            case key(start: Int)
            /// Finished a key; waiting for ':' and the beginning of the value; holds the key string.
            case waitingColonDeterminer(key: String)
            /// Accumulating the value payload for the given key; holds (start index of value, key).
            case payload(start: Int, key: String)
        }
        
        var state = State.idle
        var escape = false
        var quotation = false
        var curlyBraceDepth: Int = 0
        var squareBracketDepth = 0
        var contents: [String : Data] = [:]
        
        while index < data.endIndex - 1 {
            defer { index &+= 1 }
            
            if escape && quotation {
                escape = false
                continue // consume nevertheless
            } else if quotation && data[index] == 92 { // escape
                escape = true
                continue
            }
            
            switch data[index] {
            case 34: // "
                // Toggle quotation only if not inside nested structures in value payload
                quotation.toggle()
                
                switch state {
                case .idle:
                    state = .key(start: index + 1)
                case .key(start: let startIndex):
                    let keyData = data[(startIndex - 1) ... index]
                    let key: String
                    do {
                        key = try JSONDecoder().decode(String.self, from: keyData)
                    } catch {
                        throw ParseError(message: "Object key is not a valid string", index: startIndex, data: original)
                    }
                    state = .waitingColonDeterminer(key: key)
                default:
                    continue
                }
                
            case 44: //,
                guard !quotation, curlyBraceDepth == 0, squareBracketDepth == 0 else { continue }
                if case let .payload(start: int, key: string) = state {
                    contents[string] = data[int..<index]
                    state = .idle
                }
                
            case 58: // :
                switch state {
                case let .waitingColonDeterminer(key: key):
                    var i = index &+ 1
                    while i < data.endIndex, isJSONWhitespace(data[i]) { i &+= 1 }
                    state = .payload(start: i, key: key)
                    
                default:
                    continue
                }
                
            case 91 where !quotation: // [
                squareBracketDepth &+= 1
                
            case 93 where !quotation: // ]
                squareBracketDepth &-= 1
                if squareBracketDepth < 0 {
                    throw ParseError(message: "Misplaced ']' or missing '['", index: index, data: original)
                }
                
            case 123 where !quotation: // {
                curlyBraceDepth &+= 1
                
            case 125 where !quotation: // }
                curlyBraceDepth &-= 1
                if curlyBraceDepth < 0 {
                    throw ParseError(message: "Misplaced '}' or missing '{'", index: index, data: original)
                }
                
            default:
                continue
            }
        }
        
        switch state {
        case .idle:
            break
        case .payload(start: let int, key: let string):
            contents[string] = data[int..<index]
            
        default:
            throw ParseError(message: "Invalid or incomplete JSON object", index: index, data: original)
        }
        
        self.contents = contents
    }
    
}


extension JSONParser {
    
    /// Parse a top-level json dictionary.
    @inlinable
    public static func parse(_: JSONParser.Type, data: Data) throws(ParseError) -> JSONParser {
        try JSONParser(data: data)
    }
    
}


extension Collection {
    
    /// Drops first while the `predicate` satisfies.
    ///
    /// > Example:
    /// > ```swift
    /// > "   abc".dropFirst(while: \.isWhitespace)
    /// > // "abc"
    /// > ```
    ///
    /// - Complexity: O(*n*), where *n*: The number of elements dropped.
    @inlinable
    func dropFirst(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        var droppedCount = 0
        
        for element in self {
            guard try predicate(element) else { break }
            droppedCount += 1
        }
        
        return self.dropFirst(droppedCount)
    }
    
}

extension BidirectionalCollection {

    /// Drops last while the `predicate` satisfies.
    ///
    /// > Example:
    /// > ```swift
    /// > "abc   ".dropLast(while: \.isWhitespace)
    /// > // "abc"
    /// > ```
    ///
    /// - Complexity: O(*n*), where *n*: The number of elements dropped.
    @inlinable
    func dropLast(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        guard !self.isEmpty else { return self[self.startIndex..<self.endIndex] }
        var index = self.endIndex
        self.formIndex(&index, offsetBy: -1)
        
        var droppedCount = 0
        let startIndex = self.startIndex
        
        while try predicate(self[index]) {
            droppedCount += 1
            
            guard index > startIndex else { break }
            self.formIndex(&index, offsetBy: -1)
        }
        
        return self.dropLast(droppedCount)
    }
    
}
