import Testing
import Foundation
@testable import JSONParser


@Suite
struct JSONParserInitTests {

    @Test func simple() async throws {
        let string = #"{"a":1}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser["a"] == "1")
        #expect(parser.keys.count == 1)
        #expect(parser.keys.first == "a")
        #expect(try parser.decode(Int.self, forKey: "a") == 1)
        #expect(try parser.decodeIfPresent(String.self, forKey: "c") == nil)
    }

    @Test func error() async throws {
        let string = #"{"a":1}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser["a"] == "1")
        #expect(parser.keys.count == 1)
        #expect(parser.keys.first == "a")
        #expect(try parser.decode(Int.self, forKey: "a") == 1)
        #expect(throws: DecodingError.self) {
            try parser.decode(Int.self, forKey: "c") == 1
        }
    }

    @Test func description() async throws {
        let string = #"{"a":{"e":{"d":1}}}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        let expected = """
        {
          a: {
            e: {
              d: 1
            }
          }
        }
        """

        #expect(parser.description == expected)
    }

    @Test func description2() async throws {
        let string = "{\"a\":[{\"e\":\"d\ne\"}, {\"e\":\"d\ne\"}]}"
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        let expected = """
        {
          a: [
            {
              e: "d
                  e"
            },
            {
              e: "d
                  e"
            }
          ]
        }
        """

        #expect(parser.description == expected)
    }

    @Test func string() async throws {
        let string = #"{"a":"b"}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.count == 1)
        #expect(parser.keys.first == "a")
        #expect(try parser.decode(String.self, forKey: "a") == "b")
    }

    @Test func arrayOfInt() async throws {
        let string = #"{"a":[1, 2, 3]}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.count == 1)
        #expect(parser.keys.first == "a")
        #expect(try parser.decode([Int].self, forKey: "a") == [1, 2, 3])
    }

    @Test func unicode() async throws {
        let string = "{\"\u{1F449}\":\"\u{1F448}\"}"
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.count == 1)
        #expect(parser.keys.first == "\u{1F449}")
        #expect(try parser.decode(String.self, forKey: "\u{1F449}") == "\u{1F448}")
    }

    @Test func nested() async throws {
        let string = #"{"a":{"b": 1}}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)
        #expect(parser.keys.count == 1)
        let child = try parser.decode(JSONParser.self, forKey: "a")
        #expect(try child.decode(Int.self, forKey: "b") == 1)
    }

    @Test func nestedArray() async throws {
        let string = #"{"a":[{"b" : 1}, {}]}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.count == 1)
        #expect(parser.keys.first == "a")
        let parsers = try parser.decode([JSONParser].self, forKey: "a")
        #expect(parsers.count == 2)
        #expect(try parsers[0].decode(Int.self, forKey: "b") == 1)
        #expect(parsers[1].isEmpty)
    }

    @Test func multi() async throws {
        let string = #"{"a":1,"c":3}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.count == 2)
        #expect(Set(parser.keys) == ["a", "c"])
        #expect(try parser.decode(Int.self, forKey: "a") == 1)
        #expect(try parser.decode(Int.self, forKey: "c") == 3)
    }

    @Test func multipleTypes() async throws {
        let string = #"{"int": -42, "double": 1.0e2, "boolTrue": true, "boolFalse": false, "string": "Hello, world!"}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.count == 5)
        #expect(try parser.decode(Int.self, forKey: "int") == -42)
        #expect(try parser.decode(Double.self, forKey: "double") == 100.0)
        #expect(try parser.decode(Bool.self, forKey: "boolTrue") == true)
        #expect(try parser.decode(Bool.self, forKey: "boolFalse") == false)
        #expect(try parser.decode(String.self, forKey: "string") == "Hello, world!")
    }

    @Test func arrays() async throws {
        let string = #"{"ints":[1,2,3], "strings":["a","b","c"]}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        let ints = try parser.decode([Int].self, forKey: "ints")
        let strings = try parser.decode([String].self, forKey: "strings")

        #expect(ints == [1, 2, 3])
        #expect(strings == ["a", "b", "c"])
    }

    @Test func emptyAndWhitespace() async throws {
        let string = """
        {
            "emptyArray": [],
            "nested": {
            },
            "a" : 1 ,
            "b" : true
        }
        """
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.contains("emptyArray"))
        #expect(parser.keys.contains("nested"))
        #expect(try parser.decode([Int].self, forKey: "emptyArray").isEmpty)
        #expect(try parser.decode(Int.self, forKey: "a") == 1)
        #expect(try parser.decode(Bool.self, forKey: "b") == true)
    }

    @Test func escapedStrings() async throws {
        let dict = ["text" : "Line 1\nLine 2\tTabbed \"quote\" and backslash \\", "emoji": "😀"]

        let data = try JSONSerialization.data(withJSONObject: dict)
        let parser = try JSONParser(data: data)

        #expect(try parser.decode(String.self, forKey: "text") == "Line 1\nLine 2\tTabbed \"quote\" and backslash \\")
        #expect(try parser.decode(String.self, forKey: "emoji") == "😀")
    }

    @Test func emptyObject() async throws {
        let string = #"{}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        #expect(parser.keys.isEmpty)
    }

    @Test func arraysOfObjects() async throws {
        let string = #"{"items":[{"id":1},{"id":2},{"id":3}]}"#
        let parser = try JSONParser(data: string.data(using: .utf8)!)

        struct Item: Decodable, Equatable { let id: Int }
        let items = try parser.decode([Item].self, forKey: "items")

        #expect(items.map(\.id) == [1, 2, 3])
    }

    @Test func escapedKeyName() async throws {
        let dict = ["a\"b" : 1]

        let data = try JSONSerialization.data(withJSONObject: dict)
        let parser = try JSONParser(data: data)

        #expect(parser.keys.count == 1)
        #expect(parser.keys.first == "a\"b")
        #expect(try parser.decode(Int.self, forKey: "a\"b") == 1)
    }

    @Test func parseArrayEmpty() async throws {
        let data = "[]".data(using: .utf8)!
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        #expect(parsers.isEmpty)
    }

    @Test func parseArraySingle() async throws {
        let data = #"[{"a":1}]"#.data(using: .utf8)!
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        #expect(parsers.count == 1)
        #expect(try parsers[0].decode(Int.self, forKey: "a") == 1)
    }

    @Test func parseArrayMultiple() async throws {
        let data = #"[{"a":1}, {"b":2}, {"c":3}]"#.data(using: .utf8)!
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        #expect(parsers.count == 3)
        #expect(try parsers[0].decode(Int.self, forKey: "a") == 1)
        #expect(try parsers[1].decode(Int.self, forKey: "b") == 2)
        #expect(try parsers[2].decode(Int.self, forKey: "c") == 3)
    }

    @Test func parseArrayWithWhitespace() async throws {
        let data = " [ {\"a\":1} , {\"b\":2} ] ".data(using: .utf8)!
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        #expect(parsers.count == 2)
        #expect(try parsers[0].decode(Int.self, forKey: "a") == 1)
        #expect(try parsers[1].decode(Int.self, forKey: "b") == 2)
    }

    @Test func parseArrayNestedObjects() async throws {
        let data = #"[{"a":{"b":1}}, {"c":{"d":2}}]"#.data(using: .utf8)!
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        #expect(parsers.count == 2)
        let nested = try parsers[0].decode(JSONParser.self, forKey: "a")
        #expect(try nested.decode(Int.self, forKey: "b") == 1)
    }

    @Test func parseArrayEmptyWithWhitespace() async throws {
        let data = " [  ] ".data(using: .utf8)!
        let parsers = try JSONParser.parse([JSONParser].self, data: data)
        #expect(parsers.isEmpty)
    }
}
