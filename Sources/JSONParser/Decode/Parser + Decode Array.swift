//
//  Parser + Decode Array.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//


extension JSONParser {
    
    /// Decodes an array of dictionaries of the given type for the given key.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
    public func decode(_ type: [JSONParser].Type, forKey key: String) throws(DecodingError) -> [JSONParser] {
        try self.decodeData(type, forKey: key) {
            let parsers = try JSONParser.parse(type, data: $0)
            for parser in parsers {
                parser.keyDecodingStrategy = self.keyDecodingStrategy
            }
            return parsers
        }
    }
    
}
