//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    /// Decodes a value of the given type for the given key.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    @_disfavoredOverload
    public func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = self.contents[key] else { return nil }
        guard data != JSONParser.null else { return nil }
        return try self.decoder.decode(T.self, from: data)
    }
    
    /// Decodes a value of `Date` for the given key.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    public func decodeIfPresent(_ type: Date.Type, forKey key: String, strategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> Date? {
        guard let data = self.contents[key] else { return nil }
        guard data != JSONParser.null else { return nil }
        decoder.dateDecodingStrategy = strategy
        return try self.decoder.decode(Date.self, from: data)
    }
    
    /// Decodes a dictionary for the given key.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    public func decodeIfPresent(_ type: JSONParser.Type, forKey key: String) throws -> JSONParser? {
        guard let data = self.contents[key] else { return nil }
        guard data != JSONParser.null else { return nil }
        let parser = try JSONParser(data: data)
        parser.keyDecodingStrategy = keyDecodingStrategy
        return parser
    }
    
    /// Decodes a dictionary for the given key.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    public func decodeIfPresent(_ type: [JSONParser].Type, forKey key: String) throws -> [JSONParser]? {
        guard let data = self.contents[key] else { return nil }
        guard data != JSONParser.null else { return nil }
        let parsers = try JSONParser.parse(type.self, data: data)
        for parser in parsers {
            parser.keyDecodingStrategy = self.keyDecodingStrategy
        }
        return parsers
    }
    
}
