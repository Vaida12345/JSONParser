//
//  ErrorTests.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-03.
//

import Testing
import Foundation
@testable import JSONParser


@Suite
struct ErrorTests {
    
    @Test func typeMismatch() throws {
        let string = #"{"a":1}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)
        
        #expect {
            try parser.decode(String.self, forKey: "a") == "1"
        } throws: { error in
            guard let error = error as? DecodingError else { return false }
            switch error {
            case let .typeMismatch(type, context):
                return type is String.Type
                && context.codingPath.map(\.stringValue) == ["a"]
                && context.debugDescription == "Expected to decode String but found number instead. (raw: 1)"
                && context.underlyingError == nil
            default:
                return false
            }
        }
    }
    
    @Test func noSuchKey() throws {
        let string = #"{"a":1}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)
        
        #expect {
            try parser.decode(String.self, forKey: "c") == "1"
        } throws: { error in
            guard let error = error as? DecodingError else { return false }
            switch error {
            case let .keyNotFound(key, context):
                return key.stringValue == "c"
                && context.codingPath.map(\.stringValue) == ["c"]
                && context.debugDescription == "No value associated with key \"c\""
                && context.underlyingError == nil
            default:
                return false
            }
        }
    }
    
    @Test func valueNotFound() throws {
        let string = #"{"a":null}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)
        
        #expect {
            try parser.decode(String.self, forKey: "a") == "1"
        } throws: { error in
            guard let error = error as? DecodingError else { return false }
            switch error {
            case let .valueNotFound(_, context):
                return context.codingPath.map(\.stringValue) == ["a"]
                && context.debugDescription == "Cannot get value of type String, found null value instead"
                && context.underlyingError == nil
            default:
                return false
            }
        }
    }
    
}
