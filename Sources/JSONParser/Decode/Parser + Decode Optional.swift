//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    private static let null = Data([110, 117, 108, 108])
    
    /// Decodes a value of `Date` for the given key.
    public func decode(_ type: Date?.Type, forKey key: String, strategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> Date? {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        decoder.dateDecodingStrategy = strategy
        guard data != JSONParser.null else { return nil }
        return try self.decoder.decode(Date.self, from: data)
    }
    
    /// Decodes a dictionary for the given key.
    public func decode(_ type: JSONParser?.Type, forKey key: String) throws -> JSONParser? {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        guard data != JSONParser.null else { return nil }
        let parser = try JSONParser(data: data)
        parser.keyDecodingStrategy = keyDecodingStrategy
        return parser
    }
    
    /// Decodes a dictionary for the given key.
    public func decode(_ type: [JSONParser]?.Type, forKey key: String) throws -> [JSONParser]? {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        guard data != JSONParser.null else { return nil }
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        for parser in parsers {
            parser.keyDecodingStrategy = self.keyDecodingStrategy
        }
        return parsers
    }
    
}
