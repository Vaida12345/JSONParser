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
    public func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = self.contents[key] else { return nil }
        return try self.decoder.decode(T.self, from: data)
    }
    
    /// Decodes a value of `Date` for the given key.
    public func decodeIfPresent(_ type: Date.Type, forKey key: String, strategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> Date? {
        guard let data = self.contents[key] else { return nil }
        decoder.dateDecodingStrategy = strategy
        return try self.decoder.decode(Date.self, from: data)
    }
    
    /// Decodes a dictionary for the given key.
    public func decodeIfPresent(_ type: JSONParser.Type, forKey key: String) throws -> JSONParser? {
        guard let data = self.contents[key] else { return nil }
        let parser = try JSONParser(data: data)
        parser.keyDecodingStrategy = keyDecodingStrategy
        return parser
    }
    
    /// Decodes a dictionary for the given key.
    public func decodeIfPresent(_ type: [JSONParser]?.Type, forKey key: String) throws -> [JSONParser] {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        for parser in parsers {
            parser.keyDecodingStrategy = self.keyDecodingStrategy
        }
        return parsers
    }
    
}
