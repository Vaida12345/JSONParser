//
//  Parser + Parse Array.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    /// Parse an array of top-level json dictionaries.
    public static func parse(_: [JSONParser].Type, data: Data) throws(ParseError) -> [JSONParser] {
        let original = data
        let data = data.dropFirst(while: isJSONWhitespace)
            .dropLast(while: isJSONWhitespace)
        guard !data.isEmpty else { throw ParseError(message: "Input data is empty", index: original.startIndex, data: original) }
        guard data.first == 91 else { throw ParseError(message: "Missing start bracket '['", index: data.startIndex, data: original) }
        guard data.last == 93 else { throw ParseError(message: "Missing end bracket ']'", index: data.endIndex &- 1, data: original) }
        
        // Empty array
        if data.count == 2 { return [] }
        
        var index = data.startIndex + 1 // skip past '['
        
        // Skip whitespace to find first element (or closing bracket)
        while index < data.endIndex, isJSONWhitespace(data[index]) { index &+= 1 }
        if index == data.endIndex - 1 { return [] } // only ']' remains
        
        var elementStartIndex = index
        var escape = false
        var quotation = false
        var curlyBraceDepth: Int = 0
        var squareBracketDepth = 1 // already inside the outer array
        var contents: [JSONParser] = []
        
        while index < data.endIndex - 1 {
            defer { index &+= 1 }
            
            if escape && quotation {
                escape = false
                continue
            } else if quotation && data[index] == 92 { // escape
                escape = true
                continue
            }
            
            switch data[index] {
            case 34: // "
                quotation.toggle()
                
            case 44: // ,
                guard !quotation, curlyBraceDepth == 0, squareBracketDepth == 1 else { continue }
                try contents.append(JSONParser(data: data[elementStartIndex..<index]))
                // Skip whitespace to find next element
                elementStartIndex = index &+ 1
                while elementStartIndex < data.endIndex, isJSONWhitespace(data[elementStartIndex]) { elementStartIndex &+= 1 }
                
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
        
        // Append the final element (its data ends before ']')
        let lastEnd = data.endIndex - 1
        if elementStartIndex < lastEnd {
            try contents.append(JSONParser(data: data[elementStartIndex..<lastEnd]))
        }
        
        return contents
    }
    
}
