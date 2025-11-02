//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//


extension JSONParser {
    
    
    public func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        guard let data = self.contents[key] else { throw DecodeError.noSuchKey(key) }
    }
    
}
