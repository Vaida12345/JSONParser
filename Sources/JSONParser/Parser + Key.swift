//
//  Parser + Ley.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    /// The keys for the JSON dictionary.
    @inlinable
    public var keys: Dictionary<String, Data>.Keys { self.contents.keys }
    
    /// A value that determines how to decode a type’s coding keys from JSON keys.
    ///
    /// The strategy is only used for decoding `Decodable`s.
    @inlinable
    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        get { self.decoder.keyDecodingStrategy }
        nonmutating set { self.decoder.keyDecodingStrategy = newValue }
    }
    
}
