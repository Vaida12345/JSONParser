//
//  Parser + DecodeError.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    
    /// An error describing decoding failures produced by `JSONParser`.
    ///
    /// `DecodeError` is thrown when:
    /// - a requested key is missing from the current JSON object; or
    /// - the value found at a key cannot be converted to the requested Swift type.
    ///
    /// Conforms to `GenericError`. Its `message` provides a human‑readable description,
    /// attempting to render any associated `Data` as UTF‑8 text and falling back to
    /// "<binary data>" when decoding fails.
    ///
    /// - SeeAlso: `JSONParser`, `GenericError`
    ///
    /// Usage:
    /// ```swift
    /// do {
    ///     // try parser.decode(...)
    /// } catch let error as JSONParser.DecodeError {
    ///     print(error.message)
    /// }
    /// ```
    public enum DecodeError: Error, CustomStringConvertible {
        /// Key not found in the current JSON object.
        ///
        /// - Parameter key: The missing key.
        case noSuchKey(String)
        
        /// A value exists at the given key but could not be decoded to the expected type.
        ///
        /// - Parameters:
        ///   - key: The key at which the mismatch occurred.
        ///   - payload: The raw payload that was found at `key` (as `Data`).
        ///   - expected: A textual description of the expected type (e.g., "Int", "String", "Bool").
        case typeMismatch(key: String, payload: Data, expected: String)
        
        
        @inlinable
        public var description: String {
            switch self {
            case .noSuchKey(let string):
                "No such key: \"\(string)\""
            case .typeMismatch(let key, let data, let expected):
                "Type mismatch at \"\(key)\", expected \(expected), got \(String(data: data, encoding: .utf8) ?? "<binary data>"))."
            }
        }
        
    }
    
}
