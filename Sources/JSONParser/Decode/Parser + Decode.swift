//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    /// Decodes a value of the given type for the given key.
    public func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        return try self.decoder.decode(T.self, from: data)
    }
    
    /// Decodes a value of `Date` for the given key.
    public func decode(_ type: Date.Type, forKey key: String, strategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> Date {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        decoder.dateDecodingStrategy = strategy
        return try self.decoder.decode(Date.self, from: data)
    }
    
    /// Decodes a dictionary for the given key.
    public func decode(_ type: JSONParser.Type, forKey key: String) throws -> JSONParser {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        return try JSONParser(data: data)
    }
    
    /// Decodes a value of `String` for the given key.
    public func decode(_ type: String.Type, forKey key: String, encoding: String.Encoding = .utf8) throws -> String {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        guard var result = String(data: data, encoding: encoding) else {
            throw DecodeError.typeMismatch(key: key, data, expected: "String")
        }
        if result.hasPrefix("\"") {
            result.removeFirst()
        }
        if result.hasSuffix("\"") {
            result.removeLast()
        }
        
        return result // first and last are "
    }
    
}
