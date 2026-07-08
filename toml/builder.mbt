///|
/// TOML document builder.
///
/// Provides a convenient API for constructing TOML documents programmatically.

///|
/// A builder for constructing TOML documents.
pub(all) struct TomlBuilder {
  document : TomlDocument
  current_path : Array[String]
}

///|
/// Create a new TOML builder.
pub fn TomlBuilder::new() -> TomlBuilder {
  {
    document: empty_document(),
    current_path: [],
  }
}

///|
/// Set a string value at the given key.
pub fn TomlBuilder::set_string(self : TomlBuilder, key : String, value : String) -> TomlBuilder {
  let path = build_path(self.current_path, key)
  insert_by_path(self.document, path, TomlValue::TomlString(value))
  self
}

///|
/// Set an integer value at the given key.
pub fn TomlBuilder::set_integer(self : TomlBuilder, key : String, value : Int64) -> TomlBuilder {
  let path = build_path(self.current_path, key)
  insert_by_path(self.document, path, TomlValue::TomlInteger(value))
  self
}

///|
/// Set a float value at the given key.
pub fn TomlBuilder::set_float(self : TomlBuilder, key : String, value : Double) -> TomlBuilder {
  let path = build_path(self.current_path, key)
  insert_by_path(self.document, path, TomlValue::TomlFloat(value))
  self
}

///|
/// Set a boolean value at the given key.
pub fn TomlBuilder::set_boolean(self : TomlBuilder, key : String, value : Bool) -> TomlBuilder {
  let path = build_path(self.current_path, key)
  insert_by_path(self.document, path, TomlValue::TomlBoolean(value))
  self
}

///|
/// Set an array value at the given key.
pub fn TomlBuilder::set_array(
  self : TomlBuilder,
  key : String,
  value : Array[TomlValue],
) -> TomlBuilder {
  let path = build_path(self.current_path, key)
  insert_by_path(self.document, path, TomlValue::TomlArray(value))
  self
}

///|
/// Enter a table section. All subsequent set operations will be inside this table.
pub fn TomlBuilder::table(self : TomlBuilder, name : String) -> TomlBuilder {
  let new_path : Array[String] = []
  for key in self.current_path {
    new_path.push(key)
  }
  new_path.push(name)
  { document: self.document, current_path: new_path }
}

///|
/// Exit the current table section, returning to the parent level.
pub fn TomlBuilder::end_table(self : TomlBuilder) -> TomlBuilder {
  let new_path : Array[String] = []
  let len = self.current_path.length()
  for i = 0; i < len - 1; i = i + 1 {
    new_path.push(self.current_path[i])
  }
  { document: self.document, current_path: new_path }
}

///|
/// Get the built document.
pub fn TomlBuilder::build(self : TomlBuilder) -> TomlDocument {
  self.document
}

///|
/// Build a full key path from the current section and a key.
fn build_path(current : Array[String], key : String) -> String {
  if current.length() == 0 {
    key
  } else {
    let buf = Buffer::Buffer()
    for i = 0; i < current.length(); i = i + 1 {
      if i > 0 {
        buf.write_char('.')
      }
      buf.write_string(current[i])
    }
    buf.write_char('.')
    buf.write_string(key)
    buf.to_string()
  }
}

///|
/// Convenience function to build a simple TOML document from key-value pairs.
pub fn simple_doc(pairs : Array[(String, TomlValue)]) -> TomlDocument {
  let doc = Map::new()
  for pair in pairs {
    doc.set(pair.0, pair.1)
  }
  doc
}

///|
/// Convenience function: create a string pair.
pub fn pair_string(key : String, value : String) -> (String, TomlValue) {
  (key, TomlValue::TomlString(value))
}

///|
/// Convenience function: create an integer pair.
pub fn pair_integer(key : String, value : Int64) -> (String, TomlValue) {
  (key, TomlValue::TomlInteger(value))
}

///|
/// Convenience function: create a float pair.
pub fn pair_float(key : String, value : Double) -> (String, TomlValue) {
  (key, TomlValue::TomlFloat(value))
}

///|
/// Convenience function: create a boolean pair.
pub fn pair_boolean(key : String, value : Bool) -> (String, TomlValue) {
  (key, TomlValue::TomlBoolean(value))
}
