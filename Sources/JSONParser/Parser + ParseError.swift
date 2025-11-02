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
        
        /// One-based line number, if determinable from the input.
        public let line: Int?
        
        /// One-based column number within the line, if determinable.
        public let column: Int?
        
        /// A single-line excerpt of the input surrounding the error location, if available.
        public let context: String?
        
        /// A caret pointer aligned under `context` indicating the error position, if available.
        public let pointer: String?
        
        /// Create a decode error with rich location context derived from the original data.
        public init(message: String, index: Int, data: Data) {
            self.message = message
            self.index = index
            let info = Self.computeContext(in: data, at: index)
            self.line = info.line
            self.column = info.column
            self.context = info.context
            self.pointer = info.pointer
        }
        
        // MARK: - GenericError
        public var details: String? {
            var parts: [String] = ["byte: \(index)"]
            if let line, let column { parts.append("line: \(line), column: \(column)") }
            var out = parts.joined(separator: ", ")
            if let context {
                out += "\n" + context
                if let pointer { out += "\n" + pointer }
            }
            return out
        }
        
        // MARK: - LocalizedError
        public var errorDescription: String? { message }
        
        // MARK: - CustomStringConvertible
        public var description: String {
            if let details { return "\(message)\n\(details)" }
            return message
        }
        
        // MARK: - Context computation
        private struct ContextInfo { let line: Int?; let column: Int?; let context: String?; let pointer: String? }
        
        private static func computeContext(in data: Data, at rawIndex: Int) -> ContextInfo {
            guard !data.isEmpty else { return ContextInfo(line: nil, column: nil, context: nil, pointer: nil) }
            // Clamp index into valid range [0, data.count]
            let clamped = max(0, min(rawIndex, data.count))
            
            // Compute line/column by scanning for newlines ("\n" = 10)
            var line = 1
            var lastLineStart = 0
            var i = 0
            while i < clamped {
                if data[i] == 10 { // \n
                    line += 1
                    lastLineStart = i + 1
                }
                i &+= 1
            }
            let column = clamped - lastLineStart + 1
            
            // Determine current line slice [start, end)
            var end = clamped
            while end < data.count, data[end] != 10, data[end] != 13 { end &+= 1 }
            let start = lastLineStart
            let slice = data[start..<end]
            let context = String(decoding: slice, as: UTF8.self)
            
            // Build caret pointer aligned under the error position.
            var caretCount = 0
            var j = start
            while j < clamped {
                let b = data[j]
                // Treat tabs as a single space for alignment.
                if b == 9 { // \t
                    caretCount &+= 1
                } else if b == 13 || b == 10 {
                    caretCount = 0
                } else {
                    caretCount &+= 1
                }
                j &+= 1
            }
            let pointer = String(repeating: " ", count: max(0, caretCount)) + "^"
            
            return ContextInfo(line: line, column: column, context: context, pointer: pointer)
        }
    }
}
