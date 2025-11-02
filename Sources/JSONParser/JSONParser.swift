//
//  JSONParser.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import Foundation


/// A container for JSON dictionary.
public struct JSONParser {
    
    /// The internal decoder used when call ``decode``.
    @usableFromInline
    internal let decoder = JSONDecoder()
    
    /// Raw contents of the JSON.
    @usableFromInline
    internal let contents: [String : Data]
    
}
