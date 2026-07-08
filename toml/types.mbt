///|
/// TOML v1.0 data types and document manipulation utilities.

///|
/// All TOML value variants.
pub(all) enum TomlValue {
  TomlString(String)
  TomlInteger(Int64)
  TomlFloat(Double)
  TomlBoolean(Bool)
  TomlOffsetDateTime(String)
  TomlLocalDateTime(String)
  TomlLocalDate(String)
  TomlLocalTime(String)
  TomlArray(Array[TomlValue])
  TomlTable(Map[String, TomlValue])
} derive(Debug, Eq)

///|
/// The root of a parsed TOML document is a table.
pub(all) type TomlDocument = Map[String, TomlValue]

///|
/// Create a TOML string value.
pub fn string(value : String) -> TomlValue {
  TomlString(value)
}

///|
/// Create a TOML integer value.
pub fn integer(value : Int64) -> TomlValue {
  TomlInteger(value)
}

///|
/// Create a TOML float value.
pub fn float(value : Double) -> TomlValue {
  TomlFloat(value)
}

///|
/// Create a TOML boolean value.
pub fn boolean(value : Bool) -> TomlValue {
  TomlBoolean(value)
}

///|
/// Create a TOML array value.
pub fn array(value : Array[TomlValue]) -> TomlValue {
  TomlArray(value)
}

///|
/// Create a TOML table value.
pub fn table(value : Map[String, TomlValue]) -> TomlValue {
  TomlTable(value)
}

///|
/// Create an empty TOML document.
pub fn empty_document() -> TomlDocument {
  Map::new()
}

///|
/// Try to get a string value.
pub fn get_string(value : TomlValue) -> String? {
  match value {
    TomlString(s) => Some(s)
    _ => None
  }
}

///|
/// Try to get an integer value.
pub fn get_integer(value : TomlValue) -> Int64? {
  match value {
    TomlInteger(i) => Some(i)
    _ => None
  }
}

///|
/// Try to get a float value.
pub fn get_float(value : TomlValue) -> Double? {
  match value {
    TomlFloat(f) => Some(f)
    _ => None
  }
}

///|
/// Try to get a boolean value.
pub fn get_boolean(value : TomlValue) -> Bool? {
  match value {
    TomlBoolean(b) => Some(b)
    _ => None
  }
}

///|
/// Try to get an array value.
pub fn get_array(value : TomlValue) -> Array[TomlValue]? {
  match value {
    TomlArray(a) => Some(a)
    _ => None
  }
}

///|
/// Try to get a table value.
pub fn get_table(value : TomlValue) -> Map[String, TomlValue]? {
  match value {
    TomlTable(t) => Some(t)
    _ => None
  }
}

///|
/// Get a value by dotted key path.
pub fn get_by_path(table : Map[String, TomlValue], path : String) -> TomlValue? {
  let keys = split_dotted_key(path)
  let mut current = table
  let last_idx = keys.length() - 1
  for idx = 0; idx < last_idx; idx = idx + 1 {
    match current.get(keys[idx]) {
      Some(TomlTable(t)) => current = t
      _ => return None
    }
  }
  if keys.length() > 0 {
    current.get(keys[last_idx])
  } else {
    None
  }
}

///|
/// Insert a value at a dotted key path, creating intermediate tables.
pub fn insert_by_path(
  table : Map[String, TomlValue],
  path : String,
  value : TomlValue,
) -> Unit {
  let keys = split_dotted_key(path)
  if keys.length() == 0 {
    return
  }
  let mut current = table
  let last_idx = keys.length() - 1
  for idx = 0; idx < last_idx; idx = idx + 1 {
    let key = keys[idx]
    match current.get(key) {
      Some(TomlTable(t)) => current = t
      _ => {
        let new_table = Map::new()
        current.set(key, TomlTable(new_table))
        match current.get(key) {
          Some(TomlTable(t)) => current = t
          _ => return
        }
      }
    }
  }
  current.set(keys[last_idx], value)
}

///|
/// Check value type predicates.
pub fn is_string(value : TomlValue) -> Bool {
  match value {
    TomlString(_) => true
    _ => false
  }
}

///|
pub fn is_integer(value : TomlValue) -> Bool {
  match value {
    TomlInteger(_) => true
    _ => false
  }
}

///|
pub fn is_float(value : TomlValue) -> Bool {
  match value {
    TomlFloat(_) => true
    _ => false
  }
}

///|
pub fn is_boolean(value : TomlValue) -> Bool {
  match value {
    TomlBoolean(_) => true
    _ => false
  }
}

///|
pub fn is_array(value : TomlValue) -> Bool {
  match value {
    TomlArray(_) => true
    _ => false
  }
}

///|
pub fn is_table(value : TomlValue) -> Bool {
  match value {
    TomlTable(_) => true
    _ => false
  }
}

///|
/// Split a dotted key path into segments.
fn split_dotted_key(path : String) -> Array[String] {
  let result = Array::new()
  let mut current = Buffer::Buffer()
  for ch in path {
    if ch == '.' {
      if current.length() > 0 {
        result.push(current.to_string())
        current = Buffer::Buffer()
      }
    } else {
      current.write_char(ch)
    }
  }
  if current.length() > 0 {
    result.push(current.to_string())
  }
  result
}
