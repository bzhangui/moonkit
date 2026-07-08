///|
/// Tests for TOML serializer.

///|
test "serialize empty document" {
  let doc = empty_document()
  let output = serialize(doc)
  @test.assert_eq(output, "")
}

///|
test "serialize simple key-value pairs" {
  let doc = Map::new()
  doc.set("name", string("test"))
  doc.set("version", integer(1L))
  doc.set("enabled", boolean(true))
  let output = serialize(doc)
  @test.assert_eq(output.contains("name = \"test\""), true)
  @test.assert_eq(output.contains("version = 1"), true)
  @test.assert_eq(output.contains("enabled = true"), true)
}

///|
test "serialize float values" {
  let doc = Map::new()
  doc.set("pi", float(3.14))
  let output = serialize(doc)
  @test.assert_eq(output.contains("pi ="), true)
}

///|
test "serialize nested tables" {
  let doc = Map::new()
  let sub = Map::new()
  sub.set("key", string("value"))
  doc.set("section", TomlValue::TomlTable(sub))
  let output = serialize(doc)
  @test.assert_eq(output.contains("[section]"), true)
  @test.assert_eq(output.contains("key = \"value\""), true)
}

///|
test "serialize array" {
  let doc = Map::new()
  doc.set("items", TomlValue::TomlArray([string("a"), string("b"), integer(1L)]))
  let output = serialize(doc)
  @test.assert_eq(output.contains("items = ["), true)
  @test.assert_eq(output.contains("\"a\""), true)
  @test.assert_eq(output.contains("\"b\""), true)
}

///|
test "serialize boolean values" {
  let doc = Map::new()
  doc.set("flag_true", boolean(true))
  doc.set("flag_false", boolean(false))
  let output = serialize(doc)
  @test.assert_eq(output.contains("flag_true = true"), true)
  @test.assert_eq(output.contains("flag_false = false"), true)
}

///|
test "serialize inline table" {
  let doc = Map::new()
  let inner = Map::new()
  inner.set("x", integer(1L))
  inner.set("y", integer(2L))
  doc.set("point", TomlValue::TomlTable(inner))
  let output = serialize(doc)
  @test.assert_eq(output.length() > 0, true)
}

///|
test "is_bare_key valid" {
  // is_bare_key is private, testing indirectly through serialization
  let doc = Map::new()
  doc.set("simple_key", string("ok"))
  let output = serialize(doc)
  @test.assert_eq(output.contains("simple_key"), true)
}

///|
test "serialize string with special chars" {
  let doc = Map::new()
  doc.set("text", string("hello\nworld"))
  let output = serialize(doc)
  // Should contain escaped newline
  @test.assert_eq(output.contains("\\n"), true)
}

///|
test "serialize and deserialize concept" {
  // Build a document, serialize it, verify structure
  let doc = Map::new()
  doc.set("title", string("Test Config"))
  doc.set("count", integer(42L))

  let server = Map::new()
  server.set("host", string("localhost"))
  server.set("port", integer(8080L))
  doc.set("server", TomlValue::TomlTable(server))

  let output = serialize(doc)
  @test.assert_eq(output.contains("title"), true)
  @test.assert_eq(output.contains("count"), true)
  @test.assert_eq(output.contains("[server]"), true)
  @test.assert_eq(output.contains("host"), true)
  @test.assert_eq(output.contains("port"), true)
}

///|
test "serialize datetime strings" {
  let doc = Map::new()
  doc.set("created", TomlValue::TomlOffsetDateTime("2024-01-01T00:00:00Z"))
  let output = serialize(doc)
  @test.assert_eq(output.contains("2024-01-01T00:00:00Z"), true)
}

///|
test "serialize empty array" {
  let doc = Map::new()
  doc.set("empty", TomlValue::TomlArray([]))
  let output = serialize(doc)
  @test.assert_eq(output.contains("[]"), true)
}
