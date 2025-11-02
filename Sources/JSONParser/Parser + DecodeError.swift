//
//  Parser + DecodeError.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Essentials
import Foundation


extension JSONParser {
    
    
    public enum DecodeError: GenericError {
        case noSuchKey(String)
        case typeMismatch(key: String, Data, expected: String)
        
        public var message: String {
            switch self {
            case .noSuchKey(let string):
                "No such key: \(string)"
            case .typeMismatch(let key, let data, let expected):
                "Type mismatch at \(key), expected \(expected), got \(String(decoding: data, as: UTF8.self))."
            }
        }
        
    }
    
}
