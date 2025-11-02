//
//  Parser + Decode Array.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//


extension JSONParser {
    
    /// Decodes a dictionary for the given key.
    public func decode(_ type: [JSONParser].Type, forKey key: String) throws -> [JSONParser] {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
        return try JSONParser.parse(type, data: data)
    }
    
}
