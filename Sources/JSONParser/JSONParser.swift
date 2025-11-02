//
//  JSONParser.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


/// A container for JSON dictionary.
public struct JSONParser {
    
    /// The keys for the JSON dictionary.
    public var keys: Dictionary<String, Data>.Keys { self.contents.keys }
    
    /// Raw contents of the JSON.
    public let contents: [String : Data]
    
}
