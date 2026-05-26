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
            self.description = message
            self.index = index
            self.data = data
        }
    }
}
