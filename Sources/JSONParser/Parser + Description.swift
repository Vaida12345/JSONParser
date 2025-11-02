//
//  Parser + Description.swift
//  JSONParser
//
//  Created by Vaida on 2025-11-02.
//


extension JSONParser: CustomStringConvertible {
    
    public var description: String {
        guard !self.isEmpty else { return "{}" }
        
        var description = "{\n"
        for (key, value) in self.contents {
            let title = "  \(key): "
            description += title
            if let parser = try? self.decode(JSONParser.self, forKey: key) {
                var components = parser.description.components(separatedBy: "\n")
                let firstComponent = components.removeFirst()
                description += firstComponent
                for component in components {
                    description += "\n" + String(repeating: " ", count: 2) + component
                }
            } else if let parsers = try? self.decode([JSONParser].self, forKey: key) {
                description += "[\n  "
                let additions = parsers.map { parser in
                    var description = ""
                    var components = parser.description.components(separatedBy: "\n")
                    let firstComponent = components.removeFirst()
                    description += String(repeating: " ", count: 2) + firstComponent
                    for component in components {
                        description += "\n  " + String(repeating: " ", count: 2) + component
                    }
                    return description
                }
                
                description += additions.joined(separator: ",\n  ")
                description += "\n  ]"
            } else {
                let _description = String(data: value, encoding: .utf8) ?? "<binary>"
                var components = _description.components(separatedBy: "\n")
                let firstComponent = components.removeFirst()
                description += firstComponent
                for component in components {
                    description += "\n" + String(repeating: " ", count: title.count + 1) + component
                }
            }
            description += "\n"
        }
        return description + "}"
    }
    
}
