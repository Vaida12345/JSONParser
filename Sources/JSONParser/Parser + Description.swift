//
//  Parser + Description.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//

import DetailedDescription


extension JSONParser: CustomStringConvertible, DetailedStringConvertible {
    
    public var description: String {
        self.detailedDescription
    }
    
    public func detailedDescription(using descriptor: DetailedDescription.Descriptor<JSONParser>) -> any DescriptionBlockProtocol {
        descriptor.container {
            descriptor.forEach(self.contents) { (key, data) in
                descriptor.container(key) {
                    descriptor.constant(String(decoding: data, as: UTF8.self))
                }
            }
        }
    }
    
}
