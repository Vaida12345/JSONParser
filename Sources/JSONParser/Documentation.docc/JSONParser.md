# ``JSONParser/JSONParser``

## Overview

`JSONParser` is designed for high-performance scenarios where you need to:

- Parse a top-level JSON dictionary once, without allocating intermediate structures.
- Decode individual values lazily using `JSONDecoder` only when you need them.
- Handle nested objects by decoding another ``JSONParser`` for a key.
- Parse arrays of top-level JSON dictionaries with a dedicated helper.

It throws a ``ParseError`` if the input data isn’t a valid top-level JSON object (or array when using the array helper). When decoding values, it throws ``DecodeError`` for missing keys or type mismatches.

### How it works

At initialization, the parser walks the input bytes and records the raw `Data` slice for each top-level key. Calls to the various ``decode(_:forKey:)->T`` overloads then hand those slices to `JSONDecoder` (or apply light transformations for specialized cases like `String`), so decoding work happens only if and when you ask for a value.

In this example, you can parse and decode values lazily.

```swift
import Foundation

let data = """
{ "id": 42, "name": "Rosa", "createdAt": "2024-06-01T10:00:00Z" }
""".data(using: .utf8)!

let parser = try JSONParser(data: data)

let id: Int = try parser.decode(Int.self, forKey: "id")
let name = try parser.decode(String.self, forKey: "name")
let creationDate = try parser.decode(Date.self, forKey: "createdAt", strategy: .iso8601)
```

### Decode Optional

There are two ways to produce optional results, using ``decode(_:forKey:)->T`` with Optional type or ``decodeIfPresent(_:forKey:)->T?``.

Use the following table to differentiate.

|                | `decode` with optional | `decodeIfPresent` |
| -------------- | :--------------------: | :---------------: |
| decodes `null` | returns `nil`          | returns `nil`     |
| no such key    | throws                 | returns `nil`     |


## Topics

### Parsing
- ``init(data:)``
- ``parse(_:data:)->JSONParser``
- ``parse(_:data:)->[JSONParser]``

### Instance Properties
- ``keys``
- ``isEmpty``
- ``keyDecodingStrategy``

### Decoding
- ``decode(_:forKey:)->T``
- ``decode(_:forKey:strategy:)->Date``
- ``decode(_:forKey:)->JSONParser``
- ``decode(_:forKey:)->[JSONParser]``

### Error Types
- ``ParseError``
- ``DecodeError``
