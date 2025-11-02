//
//  Parser + Decode Array.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//


extension JSONParser {
    
    /// Decodes a dictionary for the given key.
    @inlinable
    public func decode(_ type: [JSONParser].Type, forKey key: String) throws -> [JSONParser] {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        let parsers = try JSONParser.parse(type, data: data)
        for parser in parsers {
            parser.keyDecodingStrategy = self.keyDecodingStrategy
        }
        return parsers
    }
    
}
