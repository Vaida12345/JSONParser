//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    static let null = Data([110, 117, 108, 108])
    
    func decodeData<T>(_ type: T.Type, forKey key: String, closure: (Data) throws -> T) throws(DecodingError) -> T {
        guard let data = self.contents[key] else {
            throw DecodingError.keyNotFound(
                AnyCodingKey(stringValue: key),
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "No value associated with key \"\(key)\""
                )
            )
        }
        
        guard data != JSONParser.null else {
            throw DecodingError.valueNotFound(
                Data.self,
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Cannot get value of type \(type), found null value instead"
                )
            )
        }
        
        do {
            return try closure(data)
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch(let any, let context):
                throw DecodingError.typeMismatch(
                    any,
                    DecodingError.Context(
                        codingPath: [AnyCodingKey(stringValue: key)],
                        debugDescription: context.debugDescription,
                        underlyingError: context.underlyingError
                    )
                )
            default:
                throw DecodingError.typeMismatch(
                    T.self,
                    DecodingError.Context(
                        codingPath: [AnyCodingKey(stringValue: key)],
                        debugDescription: "Cannot get value of type \(type), type mismatch",
                        underlyingError: error
                    )
                )
            }
        } catch {
            throw DecodingError.typeMismatch(
                T.self,
                DecodingError.Context(
                    codingPath: [AnyCodingKey(stringValue: key)],
                    debugDescription: "Cannot get value of type \(type), type mismatch",
                    underlyingError: error
                )
            )
        }
    }
    
    
    /// Decodes a value of the given type for the given key.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
    @_disfavoredOverload
    public func decode<T: Decodable>(_ type: T.Type, forKey key: String) throws(DecodingError) -> T {
        try self.decodeData(type, forKey: key) {
            return try self.decoder.decode(T.self, from: $0)
        }
    }
    
    /// Decodes a value of the `Date` for the given key.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///   - strategy: The strategy for decoding a date.
    ///
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
    public func decode(_ type: Date.Type, forKey key: String, strategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws(DecodingError) -> Date {
        try self.decodeData(Date.self, forKey: key) {
            decoder.dateDecodingStrategy = strategy
            return try self.decoder.decode(Date.self, from: $0)
        }
    }
    
    /// Decodes a dictionary for the given key.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///
    /// - throws: `DecodingError.keyNotFound` if `self` does not have an entry for the given key.
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null, or of there are no more values to decode.
    public func decode(_ type: JSONParser.Type, forKey key: String) throws(DecodingError) -> JSONParser {
        try self.decodeData(JSONParser.self, forKey: key) {
            let parser = try JSONParser(data: $0)
            parser.keyDecodingStrategy = keyDecodingStrategy
            return parser
        }
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
    public subscript(_ key: String) -> String? {
        guard let data = self.contents[key] else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
}
