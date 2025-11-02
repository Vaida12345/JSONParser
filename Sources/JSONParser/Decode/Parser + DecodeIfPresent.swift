//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    func decodeDataIfPresent<T>(_ type: T.Type, forKey key: String, closure: (Data) throws -> T) throws(DecodingError) -> T? {
        guard let data = self.contents[key] else { return nil }
        guard data != JSONParser.null else { return nil }
        
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
    /// This method returns `nil` if the container does not have a value associated with key, or if the value is null. The difference between these states can be distinguished using ``keys``.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    @_disfavoredOverload
    public func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: String) throws(DecodingError) -> T? {
        try self.decodeDataIfPresent(type, forKey: key) {
            return try self.decoder.decode(T.self, from: $0)
        }
    }
    
    /// Decodes a value of `Date` for the given key.
    ///
    /// This method returns `nil` if the container does not have a value associated with key, or if the value is null. The difference between these states can be distinguished using ``keys``.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///   - strategy: data decoding strategy.
    ///
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    public func decodeIfPresent(_ type: Date.Type, forKey key: String, strategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws(DecodingError) -> Date? {
        try self.decodeDataIfPresent(type, forKey: key) {
            decoder.dateDecodingStrategy = strategy
            return try self.decoder.decode(Date.self, from: $0)
        }
    }
    
    /// Decodes a dictionary for the given key.
    ///
    /// This method returns `nil` if the container does not have a value associated with key, or if the value is null. The difference between these states can be distinguished using ``keys``.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    public func decodeIfPresent(_ type: JSONParser.Type, forKey key: String) throws(DecodingError) -> JSONParser? {
        try self.decodeDataIfPresent(type, forKey: key) {
            let parser = try JSONParser(data: $0)
            parser.keyDecodingStrategy = keyDecodingStrategy
            return parser
        }
    }
    
    /// Decodes an array of dictionaries for the given key.
    ///
    /// This method returns `nil` if the container does not have a value associated with key, or if the value is null. The difference between these states can be distinguished using ``keys``.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    public func decodeIfPresent(_ type: [JSONParser].Type, forKey key: String) throws(DecodingError) -> [JSONParser]? {
        try self.decodeDataIfPresent(type, forKey: key) {
            let parsers = try JSONParser.parse(type.self, data: $0)
            for parser in parsers {
                parser.keyDecodingStrategy = self.keyDecodingStrategy
            }
            return parsers
        }
    }
    
}
