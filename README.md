# JSONParser

A lightweight, allocation‑conscious helper for extracting fields from top‑level JSON objects and arrays of objects.

Use ``JSONParser`` to quickly split a JSON payload into key–value slices and decode individual values on demand using `JSONDecoder`. This is useful when you want the convenience of `Decodable` for values without first defining a full model type for the entire payload.

> Important:
> ``JSONParser`` expects a top‑level JSON object (dictionary) for its initializer. To parse an array of objects, use the type method ``parse(_:data:)`` with the type parameter set to `[JSONParser]`.

## Overview

``JSONParser`` scans the raw bytes of a JSON payload and records the ranges corresponding to each top‑level key's value. Those slices are then decoded lazily when you call one of the ``decode(_:forKey:)`` overloads.

Initialization: 

``init(data:)`` expects a top‑level JSON object. It validates the outer braces and builds a fast lookup map from keys to raw value payloads.

Arrays: 

Use ``parse(_:data:)`` to turn a JSON array of objects into an array of ``JSONParser`` instances.

Decoding: 

Call one of the ``decode(_:forKey:)`` methods to decode a value for a specific key using `JSONDecoder`.

Errors: 

Structural parsing issues throw ``ParseError``. Missing keys or type mismatches during field decoding throw ``DecodeError``. Failures from `JSONDecoder` propagate as `DecodingError`.

Because values are decoded on demand, you can selectively decode only the fields you need. This can reduce unnecessary work compared to decoding a large model when only a few fields are required.

### Basic example

```swift
import JSONParser

// Suppose `data` contains a single top-level JSON object.
let parser = try JSONParser(data: data)

let id = try parser.decode(Int.self, forKey: "id")
let title = try parser.decode(String.self, forKey: "title")
let publishedAt = try parser.decode(Date.self, forKey: "publishedAt", strategy: .iso8601)

// Nested object
let author = try parser.decode(JSONParser.self, forKey: "author")
let authorName = try author.decode(String.self, forKey: "name")
```
