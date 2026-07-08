///|
/// TOML document serializer.
///
/// Serializes a TOML document (Map of key-value pairs) back into
/// a valid TOML-formatted string.

///|
/// Serialize a TOML document to a string.
pub fn serialize(doc : TomlDocument) -> String {
  let buf = Buffer::Buffer()
  serialize_table_top(doc, buf)
  buf.to_string()
}

///|
/// Serialize the top-level table.
fn serialize_table_top(table : Map[String, TomlValue], buf : Buffer) -> Unit {
  // Collect keys, separating simple values from subtables
  let simple_keys : Array[String] = []
  let table_keys : Array[String] = []
  let array_table_keys : Array[String] = []

  // Scan all entries first to categorize
  for key in table.keys() {
    match table.get(key) {
      Some(TomlTable(_)) => table_keys.push(key)
      Some(TomlArray(arr)) => {
        if arr.length() > 0 {
          match arr[0] {
            TomlTable(_) => array_table_keys.push(key)
            _ => simple_keys.push(key)
          }
        } else {
          simple_keys.push(key)
        }
      }
      _ => simple_keys.push(key)
    }
  }

  // Write simple key-values first
  let mut first_item = true
  for key in simple_keys {
    match table.get(key) {
      Some(value) => {
        write_keyval(buf, key, value)
        buf.write_char('\n')
        first_item = false
      }
      _ => ()
    }
  }

  // Write regular tables
  for key in table_keys {
    match table.get(key) {
      Some(TomlTable(t)) => {
        if !first_item {
          buf.write_char('\n')
        }
        first_item = false
        buf.write_string("[\{key}]\n")
        serialize_table_body(t, buf, key)
      }
      _ => ()
    }
  }

  // Write array of tables
  for key in array_table_keys {
    match table.get(key) {
      Some(TomlArray(arr)) => {
        for item in arr {
          match item {
            TomlTable(t) => {
              if !first_item {
                buf.write_char('\n')
              }
              first_item = false
              buf.write_string("[[\{key}]]\n")
              serialize_table_body(t, buf, key)
            }
            _ => ()
          }
        }
      }
      _ => ()
    }
  }
}

///|
/// Serialize a table body (key-value pairs only, no sub-headers).
fn serialize_table_body(
  table : Map[String, TomlValue],
  buf : Buffer,
  _prefix : String,
) -> Unit {
  for key in table.keys() {
    match table.get(key) {
      Some(value) => {
        match value {
          TomlTable(_) | TomlArray(_) => {
            // Subtables are handled by the caller
            continue
          }
          _ => {
            write_keyval(buf, key, value)
            buf.write_char('\n')
          }
        }
      }
      _ => ()
    }
  }
}

///|
/// Write a key-value pair.
fn write_keyval(buf : Buffer, key : String, value : TomlValue) -> Unit {
  write_key(buf, key)
  buf.write_string(" = ")
  write_value(buf, value)
}

///|
/// Write a TOML key, quoting if necessary.
fn write_key(buf : Buffer, key : String) -> Unit {
  if is_bare_key(key) {
    buf.write_string(key)
  } else {
    write_basic_string(buf, key)
  }
}

///|
/// Write any TOML value.
fn write_value(buf : Buffer, value : TomlValue) -> Unit {
  match value {
    TomlString(s) => write_basic_string(buf, s)
    TomlInteger(i) => buf.write_string(i.to_string())
    TomlFloat(f) => write_float(buf, f)
    TomlBoolean(b) => {
      if b {
        buf.write_string("true")
      } else {
        buf.write_string("false")
      }
    }
    TomlOffsetDateTime(s) => buf.write_string(s)
    TomlLocalDateTime(s) => buf.write_string(s)
    TomlLocalDate(s) => buf.write_string(s)
    TomlLocalTime(s) => buf.write_string(s)
    TomlArray(arr) => write_array(buf, arr)
    TomlTable(t) => write_inline_table(buf, t)
  }
}

///|
/// Write a basic string (double-quoted with escaping).
fn write_basic_string(buf : Buffer, s : String) -> Unit {
  buf.write_char('"')
  for ch in s {
    match ch {
      '"' => buf.write_string("\\\"")
      '\\' => buf.write_string("\\\\")
      '\b' => buf.write_string("\\b")
      '\t' => buf.write_string("\\t")
      '\n' => buf.write_string("\\n")
      '\x0C' => buf.write_string("\\f")
      '\r' => buf.write_string("\\r")
      _ => {
        let code = ch.to_int()
        if code < 0x20 || code == 0x7F {
          buf.write_string("\\u")
          buf.write_string(hex4(code))
        } else {
          buf.write_char(ch)
        }
      }
    }
  }
  buf.write_char('"')
}

///|
/// Format an integer as a 4-digit hex string.
fn hex4(n : Int) -> String {
  let hex = "0123456789ABCDEF"
  let c1 = char_at_idx(hex, (n >> 12) & 0xF)
  let c2 = char_at_idx(hex, (n >> 8) & 0xF)
  let c3 = char_at_idx(hex, (n >> 4) & 0xF)
  let c4 = char_at_idx(hex, n & 0xF)
  let buf = Buffer::Buffer()
  buf.write_char(c1)
  buf.write_char(c2)
  buf.write_char(c3)
  buf.write_char(c4)
  buf.to_string()
}

///|
/// Get character at a given index in a string.
fn char_at_idx(s : String, idx : Int) -> Char {
  let mut i = 0
  for ch in s {
    if i == idx {
      return ch
    }
    i = i + 1
  }
  '0'
}

///|
/// Write a float value.
fn write_float(buf : Buffer, f : Double) -> Unit {
  let bits = f.reinterpret_as_int64()
  if bits == 0x7FF0000000000000L {
    buf.write_string("inf")
  } else if bits == 0xFFF0000000000000L {
    buf.write_string("-inf")
  } else if bits == 0x7FF8000000000001L {
    buf.write_string("nan")
  } else {
    buf.write_string(f.to_string())
  }
}

///|
/// Write a TOML array.
fn write_array(buf : Buffer, arr : Array[TomlValue]) -> Unit {
  buf.write_char('[')
  for i = 0; i < arr.length(); i = i + 1 {
    if i > 0 {
      buf.write_string(", ")
    }
    write_value(buf, arr[i])
  }
  buf.write_char(']')
}

///|
/// Write an inline table.
fn write_inline_table(buf : Buffer, table : Map[String, TomlValue]) -> Unit {
  buf.write_char('{')
  let mut first = true
  for key in table.keys() {
    if !first {
      buf.write_string(", ")
    }
    first = false
    write_key(buf, key)
    buf.write_string(" = ")
    match table.get(key) {
      Some(v) => write_value(buf, v)
      _ => buf.write_string("\"\"")
    }
  }
  buf.write_char('}')
}

///|
/// Check if a string is a valid bare key.
fn is_bare_key(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  for ch in s {
    if !ch.is_ascii_alphabetic() && !ch.is_digit(10U) && ch != '-' && ch != '_' {
      return false
    }
  }
  true
}
