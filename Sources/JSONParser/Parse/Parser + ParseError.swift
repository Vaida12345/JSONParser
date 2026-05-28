//
//  Parser + ParseError.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    /// Error decoding JSON data.
    public struct ParseError: CustomStringConvertible, Error {
        
        /// A human-readable summary of the failure.
        public let description: String
        
        /// The zero-based byte index into the provided data where the error was detected.
        public let index: Int
        
        /// The failed payload.
        public let data: Data
        
        /// Create a decode error with rich location context derived from the original data.
        public init(message: String, index: Int, data: Data) {
            var description = message
            description += " at byte \(index)"
            if index < data.endIndex {
                let start = max(data.startIndex, index)
                let end = min(data.endIndex, index + 50)
                let snippet = data[start..<end]
                if let preview = String(data: snippet, encoding: .utf8), !preview.isEmpty {
                    description += " near: \"\(preview)\""
                }
            }
            self.description = description
            self.index = index
            self.data = data
        }
    }
}
