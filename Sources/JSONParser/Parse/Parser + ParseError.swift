//
//  Parser + ParseError.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Essentials
import Foundation


extension JSONParser {
    
    /// Error decoding JSON data.
    public struct ParseError: GenericError, CustomStringConvertible, LocalizedError {
        
        /// A human-readable summary of the failure.
        public let message: String
        
        /// The zero-based byte index into the provided data where the error was detected.
        public let index: Int
        
        /// Create a decode error with rich location context derived from the original data.
        public init(message: String, index: Int, data: Data) {
            self.message = message
            self.index = index
        }
        
        public var details: String? {
            "data offset: \(index)"
        }
    }
}
