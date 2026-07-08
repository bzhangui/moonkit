///|
/// Data conversion utilities.

///|
/// Try to parse a Bool from a string.
/// Accepts: "true", "false", "1", "0", "yes", "no", "on", "off" (case-insensitive).
pub fn parse_bool(s : String) -> Bool? {
  let lower = s.to_lower()
  if lower == "true" || lower == "1" || lower == "yes" || lower == "on" {
    Some(true)
  } else if lower == "false" || lower == "0" || lower == "no" || lower == "off" {
    Some(false)
  } else {
    None
  }
}

///|
/// Format an integer with thousands separators.
pub fn format_with_separator(n : Int) -> String {
  let s = n.to_string()
  if s.length() <= 3 {
    return s
  }
  let buf = Buffer::Buffer()
  let mut i = 0
  let mut neg = false
  for ch in s {
    if i == 0 && ch == '-' {
      buf.write_char('-')
      neg = true
      i = i + 1
      continue
    }
    let pos = if neg { i - 1 } else { i }
    let remaining = s.length() - (if neg { 1 } else { 0 }) - pos
    if pos > 0 && remaining % 3 == 0 {
      buf.write_char(',')
    }
    buf.write_char(ch)
    i = i + 1
  }
  buf.to_string()
}

///|
/// Truncate a string to max_len, appending "..." if truncated.
pub fn truncate(s : String, max_len : Int) -> String {
  if s.length() <= max_len {
    return s
  }
  if max_len <= 3 {
    return substring_len(s, 0, max_len)
  }
  let truncated = substring_len(s, 0, max_len - 3)
  "\{truncated}..."
}

///|
/// Pad a string on the left to the given width.
pub fn pad_left(s : String, width : Int, pad_char : Char) -> String {
  if s.length() >= width {
    return s
  }
  let buf = Buffer::Buffer()
  for i = 0; i < width - s.length(); i = i + 1 {
    buf.write_char(pad_char)
  }
  buf.write_string(s)
  buf.to_string()
}

///|
/// Pad a string on the right to the given width.
pub fn pad_right(s : String, width : Int, pad_char : Char) -> String {
  if s.length() >= width {
    return s
  }
  let buf = Buffer::Buffer()
  buf.write_string(s)
  for i = 0; i < width - s.length(); i = i + 1 {
    buf.write_char(pad_char)
  }
  buf.to_string()
}

///|
/// Join an array of strings with a delimiter.
pub fn join(strings : Array[String], delim : String) -> String {
  if strings.length() == 0 {
    return ""
  }
  let buf = Buffer::Buffer()
  for i = 0; i < strings.length(); i = i + 1 {
    if i > 0 {
      buf.write_string(delim)
    }
    buf.write_string(strings[i])
  }
  buf.to_string()
}

///|
/// Repeat a string n times.
pub fn repeat(s : String, n : Int) -> String {
  let buf = Buffer::Buffer()
  for i = 0; i < n; i = i + 1 {
    buf.write_string(s)
  }
  buf.to_string()
}

///|
/// Reverse a string.
pub fn reverse(s : String) -> String {
  let buf = Buffer::Buffer()
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  let mut i = chars.length()
  while i > 0 {
    i = i - 1
    buf.write_char(chars[i])
  }
  buf.to_string()
}

///|
/// Count occurrences of a character in a string.
pub fn count_char(s : String, target : Char) -> Int {
  let mut count = 0
  for ch in s {
    if ch == target {
      count = count + 1
    }
  }
  count
}

///|
/// Check if a string is a valid integer representation.
pub fn is_int_string(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut first = true
  for ch in s {
    if first && (ch == '-' || ch == '+') {
      first = false
    } else if ch.is_digit(10U) {
      first = false
    } else {
      return false
    }
  }
  true
}

///|
/// Check if a string is a valid float representation.
pub fn is_float_string(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut has_dot = false
  let mut has_digit = false
  let mut first = true
  for ch in s {
    if first && (ch == '-' || ch == '+') {
      first = false
    } else if ch == '.' && !has_dot {
      has_dot = true
      first = false
    } else if ch.is_digit(10U) {
      has_digit = true
      first = false
    } else {
      return false
    }
  }
  has_digit
}

///|
/// Get a substring by start index and length.
fn substring_len(s : String, start : Int, len : Int) -> String {
  s.substring(start=start, end=start + len)
}
