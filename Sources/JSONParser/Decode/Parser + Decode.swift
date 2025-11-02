//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    /// Decodes a value of the given type for the given key.
    @_disfavoredOverload
    @inlinable
    public func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        return try self.decoder.decode(T.self, from: data)
    }
    
    /// Decodes a value of `Date` for the given key.
    @inlinable
    public func decode(_ type: Date.Type, forKey key: String, strategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> Date {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        decoder.dateDecodingStrategy = strategy
        return try self.decoder.decode(Date.self, from: data)
    }
    
    /// Decodes a dictionary for the given key.
    @inlinable
    public func decode(_ type: JSONParser.Type, forKey key: String) throws -> JSONParser {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        let parser = try JSONParser(data: data)
        parser.keyDecodingStrategy = keyDecodingStrategy
        return parser
    }
    
    
    /// Returns the content associated with `key`, expressed as `String`.
    ///
    /// You can use this method to access the underlying raw string.
    ///
    /// ```swift
    /// let data = #"{"a":1}"#.data(using: .utf8)!
    ///
    /// let parser = try JSONParser(data: string)
    /// parser["a"] // "1"
    /// ```
    @inlinable
    public subscript(_ key: String) -> String? {
        guard let data = self.contents[key] else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
}
