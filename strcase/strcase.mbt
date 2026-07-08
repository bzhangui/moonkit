///|
/// String case conversion utilities.

///|
/// Convert a string to camelCase.
pub fn to_camel(s : String) -> String {
  let words = split_words(s)
  if words.length() == 0 {
    return ""
  }
  let buf = Buffer::Buffer()
  buf.write_string(lowercase_first(words[0]))
  for i = 1; i < words.length(); i = i + 1 {
    buf.write_string(capitalize_first(words[i]))
  }
  buf.to_string()
}

///|
/// Convert a string to PascalCase.
pub fn to_pascal(s : String) -> String {
  let words = split_words(s)
  let buf = Buffer::Buffer()
  for i = 0; i < words.length(); i = i + 1 {
    buf.write_string(capitalize_first(words[i]))
  }
  buf.to_string()
}

///|
/// Convert a string to snake_case.
pub fn to_snake(s : String) -> String {
  let words = split_words(s)
  let buf = Buffer::Buffer()
  for i = 0; i < words.length(); i = i + 1 {
    if i > 0 {
      buf.write_char('_')
    }
    buf.write_string(words[i].to_lower())
  }
  buf.to_string()
}

///|
/// Convert a string to UPPER_SNAKE_CASE.
pub fn to_upper_snake(s : String) -> String {
  let words = split_words(s)
  let buf = Buffer::Buffer()
  for i = 0; i < words.length(); i = i + 1 {
    if i > 0 {
      buf.write_char('_')
    }
    buf.write_string(words[i].to_upper())
  }
  buf.to_string()
}

///|
/// Convert a string to kebab-case.
pub fn to_kebab(s : String) -> String {
  let words = split_words(s)
  let buf = Buffer::Buffer()
  for i = 0; i < words.length(); i = i + 1 {
    if i > 0 {
      buf.write_char('-')
    }
    buf.write_string(words[i].to_lower())
  }
  buf.to_string()
}

///|
/// Convert a string to Title Case.
pub fn to_title(s : String) -> String {
  let words = split_words(s)
  let buf = Buffer::Buffer()
  for i = 0; i < words.length(); i = i + 1 {
    if i > 0 {
      buf.write_char(' ')
    }
    buf.write_string(capitalize_first(words[i].to_lower()))
  }
  buf.to_string()
}

///|
/// Check if a string is in camelCase format.
pub fn is_camel(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut first = true
  for ch in s {
    if ch == '_' || ch == '-' {
      return false
    }
    if first {
      if ch.is_ascii_uppercase() {
        return false
      }
      first = false
    }
  }
  true
}

///|
/// Check if a string is in snake_case format.
pub fn is_snake(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  for ch in s {
    if ch.is_ascii_uppercase() {
      return false
    }
    if ch == '-' {
      return false
    }
  }
  true
}

///|
/// Split a string into words based on delimiters and case boundaries.
fn split_words(s : String) -> Array[String] {
  if s.length() == 0 {
    return Array::new()
  }
  let words = Array::new()
  let mut current_word = Buffer::Buffer()
  let mut prev_category = 0
  let mut started = false

  for ch in s {
    if ch == '_' || ch == '-' || ch == ' ' || ch == '.' {
      if started {
        words.push(current_word.to_string())
        current_word = Buffer::Buffer()
        started = false
      }
      prev_category = 0
    } else if ch.is_ascii_uppercase() {
      if prev_category == 1 && started {
        words.push(current_word.to_string())
        current_word = Buffer::Buffer()
      }
      current_word.write_char(ch.to_ascii_lowercase())
      started = true
      prev_category = 2
    } else if ch.is_digit(10U) {
      if started && prev_category != 3 {
        words.push(current_word.to_string())
        current_word = Buffer::Buffer()
      }
      current_word.write_char(ch)
      started = true
      prev_category = 3
    } else {
      current_word.write_char(ch)
      started = true
      prev_category = 1
    }
  }

  if started && current_word.length() > 0 {
    words.push(current_word.to_string())
  }

  words
}

///|
/// Capitalize the first character of a string.
fn capitalize_first(s : String) -> String {
  if s.length() == 0 {
    return ""
  }
  let mut first = true
  let buf = Buffer::Buffer()
  for ch in s {
    if first {
      buf.write_char(ch.to_ascii_uppercase())
      first = false
    } else {
      buf.write_char(ch)
    }
  }
  buf.to_string()
}

///|
/// Lowercase the first character of a string.
fn lowercase_first(s : String) -> String {
  if s.length() == 0 {
    return ""
  }
  let mut first = true
  let buf = Buffer::Buffer()
  for ch in s {
    if first {
      buf.write_char(ch.to_ascii_lowercase())
      first = false
    } else {
      buf.write_char(ch)
    }
  }
  buf.to_string()
}
