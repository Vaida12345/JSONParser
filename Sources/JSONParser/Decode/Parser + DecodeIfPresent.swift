//
//  Parser + Decode.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    func decodeDataIfPresent<T>(_ type: T.Type, forKey key: String, closure: (Data) throws -> T) throws(DecodingError) -> T? {
        guard let raw = self.contents[key] else { return nil }
        let data = raw.dropFirst(while: isJSONWhitespace).dropLast(while: isJSONWhitespace)
        guard data != JSONParser.null else { return nil }

        do {
            return try closure(data)
        } catch let error as DecodingError {
            let rawPreview = String(data: data.prefix(100), encoding: .utf8) ?? "<\(data.count) bytes>"
            switch error {
            case .typeMismatch(let any, let context):
                throw DecodingError.typeMismatch(
                    any,
                    DecodingError.Context(
                        codingPath: [AnyCodingKey(stringValue: key)] + context.codingPath,
                        debugDescription: "\(context.debugDescription) (raw: \(rawPreview))",
                        underlyingError: context.underlyingError
                    )
                )
            case .valueNotFound(let any, let context):
                throw DecodingError.valueNotFound(
                    any,
                    DecodingError.Context(
                        codingPath: [AnyCodingKey(stringValue: key)] + context.codingPath,
                        debugDescription: "\(context.debugDescription) (raw: \(rawPreview))",
                        underlyingError: context.underlyingError
                    )
                )
            case .keyNotFound(let codingKey, let context):
                throw DecodingError.keyNotFound(
                    codingKey,
                    DecodingError.Context(
                        codingPath: [AnyCodingKey(stringValue: key)] + context.codingPath,
                        debugDescription: context.debugDescription,
                        underlyingError: context.underlyingError
                    )
                )
            case .dataCorrupted(let context):
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [AnyCodingKey(stringValue: key)] + context.codingPath,
                        debugDescription: "\(context.debugDescription) (raw: \(rawPreview))",
                        underlyingError: context.underlyingError
                    )
                )
            @unknown default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [AnyCodingKey(stringValue: key)],
                        debugDescription: "Unknown decoding error for key \"\(key)\"",
                        underlyingError: error
                    )
                )
            }
        } catch {
            let rawPreview = String(data: data.prefix(100), encoding: .utf8) ?? "<\(data.count) bytes>"
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [AnyCodingKey(stringValue: key)],
                    debugDescription: "Cannot decode value of type \(type) from: \(rawPreview)",
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
    @available(macOS 14, iOS 17, tvOS 17, visionOS 1, watchOS 10, *)
    public func decodeIfPresent<T: DecodableWithConfiguration>(_ type: T.Type, forKey key: String, configuration: T.DecodingConfiguration) throws(DecodingError) -> T? {
        try self.decodeDataIfPresent(type, forKey: key) {
            return try self.decoder.decode(T.self, from: $0, configuration: configuration)
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
    
    /// Decodes a value of the `FloatingPoint` for the given key.
    ///
    /// This method returns `nil` if the container does not have a value associated with key, or if the value is null. The difference between these states can be distinguished using ``keys``.
    ///
    /// - parameters:
    ///   - type: The type of value to decode.
    ///   - key: The key that the decoded value is associated with.
    ///   - strategy: The strategy for decoding an exceptional floating-point value.
    ///
    /// - throws: `DecodingError.typeMismatch` if the encountered encoded value is not convertible to the requested type.
    ///
    /// - Returns: A decoded value of the requested type, or nil if the Decoder does not have an entry associated with the given key, or if the value is a null value.
    public func decodeIfPresent<T>(_ type: T.Type, forKey key: String, strategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw) throws(DecodingError) -> T? where T: FloatingPoint & Decodable {
        try self.decodeDataIfPresent(T.self, forKey: key) {
            decoder.nonConformingFloatDecodingStrategy = strategy
            return try self.decoder.decode(T.self, from: $0)
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
