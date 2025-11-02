//
//  Parser + Parse Array.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    /// Parse an array of top-level json dictionaries.
    public static func parse(_ type: [JSONParser].Type, data: Data) throws(ParseError) -> [JSONParser] {
        var index = data.startIndex
        
        var elementStartIndex: Int? = nil
        var escape = false
        var quotation = false
        var curlyBraceDepth: Int = 0
        var squareBracketDepth = 0
        var contents: [JSONParser] = []
        
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
                quotation.toggle()
                
            case 44: //,
                guard !quotation, curlyBraceDepth == 0, squareBracketDepth == 1 else { continue }
                if let _elementStartIndex = elementStartIndex {
                    try contents.append(JSONParser(data: data[_elementStartIndex..<index]))
                    elementStartIndex = index + 1
                }
                
            case 91 where !quotation: // [
                if squareBracketDepth == 0 {
                    elementStartIndex = index + 1
                }
                squareBracketDepth &+= 1
                
            case 93 where !quotation: // ]
                squareBracketDepth &-= 1
                if squareBracketDepth < 0 {
                    throw ParseError(message: "Misplaced ']' or missing '['", index: index, data: data)
                }
                
            case 123 where !quotation: // {
                curlyBraceDepth &+= 1
                
            case 125 where !quotation: // }
                curlyBraceDepth &-= 1
                if curlyBraceDepth < 0 {
                    throw ParseError(message: "Misplaced '}' or missing '{'", index: index, data: data)
                }
                
            default:
                continue
            }
        }
        
        if let elementStartIndex {
            try contents.append(JSONParser(data: data[elementStartIndex..<index]))
        } else {
            throw ParseError(message: "Invalid or incomplete JSON array", index: index, data: data)
        }
        
        return contents
    }
    
}
