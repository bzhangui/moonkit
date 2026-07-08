# MoonKit

A comprehensive utility toolkit for the [MoonBit](https://www.moonbitlang.com/) programming language, designed to fill gaps in the standard library and accelerate application development.

## Packages

| Package | Description |
|---------|-------------|
| `toml` | TOML v1.0 data types, document manipulation, serializer, and builder |
| `semver` | Semantic Versioning 2.0.0 parser, comparator, and version range matching |
| `ulid` | ULID unique identifier generation and validation |
| `strcase` | String case conversion (camelCase, PascalCase, snake_case, kebab-case) |
| `validators` | Data validation functions (email, URL, length, format) and schema-based validation |
| `convert` | Data conversion utilities (string parsing, formatting, padding, hex encoding) |

## Usage

```moonbit
// Semantic Versioning
let v = @moonkit/semver.parse("1.2.3-alpha+build.1")
println(v.to_string())

// String Case Conversion
let camel = @moonkit/strcase.to_camel("hello_world")
let snake = @moonkit/strcase.to_snake("helloWorld")

// Data Validation
match @moonkit/validators.validate_email("user@example.com") {
  Ok(_) => println("Valid email")
  Err(msg) => println(msg)
}

// TOML Document Builder
let builder = @moonkit/toml.TomlBuilder::new()
let builder = builder.set_string("title", "My Config")
let builder = builder.set_integer("version", 1L)
let doc = builder.build()
let output = @moonkit/toml.serialize(doc)
```

## Installation

```
moon add username/moonkit
```

## Project Structure

```
moonkit/
├── toml/          TOML data types, serializer, builder
├── semver/        Semantic versioning
├── strcase/       String case conversion
├── ulid/          ULID generation
├── validators/    Data validation & schema
└── convert/       Data conversion utilities
```

## License

Apache-2.0

## About

This project is part of the MoonBit Open Source Competition 2026 (OSC 2026).
