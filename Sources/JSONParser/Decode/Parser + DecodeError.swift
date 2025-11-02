//
//  Parser + DecodeError.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


extension JSONParser {
    
    struct AnyCodingKey: CodingKey, CustomStringConvertible {
        
        var stringValue: String
        
        var intValue: Int? { nil }
        
        var description: String {
            "\"\(self.stringValue)\""
        }
        
        
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
    
}
