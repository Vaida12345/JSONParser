import Testing
@testable import JSONParser


@Suite
struct JSONParserInitTests {
    
    @Test func simple() async throws {
        let string = #"{"a":1}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)
        print(parser)
    }
    
    @Test func unicode() async throws {
        let string = #"{"\u{1F449}":你好}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)
        print(parser)
    }
    
    @Test func nested() async throws {
        let string = #"{"a":{"b": []}}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)
        print(parser)
    }
    
    
}
