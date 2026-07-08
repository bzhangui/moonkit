///|
/// Semantic Versioning 2.0.0 parser.

///|
/// Error type for version parsing failures.
pub(all) suberror ParseError {
  InvalidFormat(String)
  InvalidNumber(String)
  EmptyIdentifier(String)
  LeadingZero(String)
} derive(Debug, Eq)

///|
/// Parse a version string into a SemVer.
pub fn parse(input : String) -> SemVer raise ParseError {
  if input.length() == 0 {
    raise InvalidFormat("empty string")
  }

  let s = input

  let plus_pos = index_of_char(s, '+')
  let hyphen_pos = index_of_char(s, '-')

  let core_end = match hyphen_pos {
    Some(h) => h
    None => match plus_pos {
      Some(p) => p
      None => s.length()
    }
  }

  let core = s.substring(start=0, end=core_end)
  let parts = split_by_char(core, '.')
  if parts.length() != 3 {
    raise InvalidFormat("version core must have exactly 3 parts")
  }

  let major = match parse_non_neg_int(parts[0]) {
    Ok(v) => v
    Err(msg) => raise InvalidNumber(msg)
  }
  let minor = match parse_non_neg_int(parts[1]) {
    Ok(v) => v
    Err(msg) => raise InvalidNumber(msg)
  }
  let patch = match parse_non_neg_int(parts[2]) {
    Ok(v) => v
    Err(msg) => raise InvalidNumber(msg)
  }

  let prerelease = match hyphen_pos {
    Some(start) => {
      let end = match plus_pos {
        Some(pp) => if pp > start { pp } else { s.length() }
        None => s.length()
      }
      if start + 1 >= end {
        raise EmptyIdentifier("prerelease is empty")
      }
      let pre_str = s.substring(start=start + 1, end=end)
      parse_identifiers(pre_str)
    }
    None => Array::new()
  }

  let build = match plus_pos {
    Some(start) => {
      if start + 1 >= s.length() {
        raise EmptyIdentifier("build metadata is empty")
      }
      let build_str = s.substring(start=start + 1, end=s.length())
      parse_identifiers(build_str)
    }
    None => Array::new()
  }

  {
    major,
    minor,
    patch,
    prerelease,
    build,
  }
}

///|
/// Parse a version string, returning Result.
pub fn parse_result(input : String) -> Result[SemVer, ParseError] {
  try {
    Ok(parse(input))
  } catch {
    e => Err(e)
  }
}

///|
/// Find the index of a character in a string.
fn index_of_char(s : String, target : Char) -> Int? {
  let mut idx = 0
  for ch in s {
    if ch == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
/// Split a string by a character delimiter.
fn split_by_char(s : String, delim : Char) -> Array[String] {
  let result = Array::new()
  let mut current = Buffer::Buffer()
  for ch in s {
    if ch == delim {
      result.push(current.to_string())
      current = Buffer::Buffer()
    } else {
      current.write_char(ch)
    }
  }
  result.push(current.to_string())
  result
}

///|
/// Parse a non-negative integer, rejecting leading zeros.
fn parse_non_neg_int(s : String) -> Result[Int, String] {
  if s.length() == 0 {
    return Err("empty identifier")
  }
  // Check for leading zeros
  if s.length() > 1 {
    let mut first_char = None
    for ch in s {
      first_char = Some(ch)
      break
    }
    match first_char {
      Some('0') => return Err("numeric identifier must not have leading zeros: \{s}")
      _ => ()
    }
  }
  let mut value = 0
  for ch in s {
    if ch.is_digit(10U) {
      value = value * 10 + (ch.to_int() - '0'.to_int())
    } else {
      return Err("invalid character in number: \{ch}")
    }
  }
  Ok(value)
}

///|
/// Parse dot-separated identifiers for prerelease/build.
fn parse_identifiers(s : String) -> Array[String] raise ParseError {
  if s.length() == 0 {
    raise EmptyIdentifier("identifier part is empty")
  }
  let parts = split_by_char(s, '.')
  for part in parts {
    if part.length() == 0 {
      raise EmptyIdentifier("identifier part is empty")
    }
    // Check for leading zeros in numeric identifiers
    if part.length() > 1 {
      let mut first_char = None
      for ch in part {
        first_char = Some(ch)
        break
      }
      match first_char {
        Some('0') => {
          let mut all_digits = true
          for ch in part {
            if !ch.is_digit(10U) {
              all_digits = false
            }
          }
          if all_digits {
            raise LeadingZero("numeric identifier has leading zero: \{part}")
          }
        }
        _ => ()
      }
    }
  }
  parts
}
