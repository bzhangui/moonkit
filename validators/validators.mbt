///|
/// Common data validation functions.

///|
/// A validation result.
pub(all) type ValidationResult = Result[Unit, String]

///|
/// Create a validation success.
pub fn valid() -> ValidationResult {
  Ok(())
}

///|
/// Create a validation failure with a message.
pub fn invalid(msg : String) -> ValidationResult {
  Err(msg)
}

///|
/// Validate that a string is not empty.
pub fn validate_not_empty(value : String, field_name : String) -> ValidationResult {
  if value.length() == 0 {
    invalid("\{field_name} must not be empty")
  } else {
    valid()
  }
}

///|
/// Validate that a string's length is within [min, max].
pub fn validate_length(
  value : String,
  min : Int,
  max : Int,
  field_name : String,
) -> ValidationResult {
  let len = value.length()
  if len < min {
    invalid("\{field_name} must be at least \{min} characters")
  } else if len > max {
    invalid("\{field_name} must be at most \{max} characters")
  } else {
    valid()
  }
}

///|
/// Validate that an integer is within [min, max].
pub fn validate_range(
  value : Int,
  min : Int,
  max : Int,
  field_name : String,
) -> ValidationResult {
  if value < min {
    invalid("\{field_name} must be at least \{min}")
  } else if value > max {
    invalid("\{field_name} must be at most \{max}")
  } else {
    valid()
  }
}

///|
/// Validate an email address with basic format checks.
pub fn validate_email(value : String) -> ValidationResult {
  if value.length() == 0 {
    return invalid("email must not be empty")
  }

  for ch in value {
    if ch == ' ' {
      return invalid("email must not contain spaces")
    }
  }

  let at_pos = find_char_pos(value, '@')
  match at_pos {
    None => invalid("email must contain '@'")
    Some(pos) => {
      if pos == 0 {
        return invalid("email local part must not be empty")
      }
      if pos == value.length() - 1 {
        return invalid("email domain must not be empty")
      }

      let domain_len = value.length() - pos - 1
      let domain = value.substring(start=pos + 1, end=pos + 1 + domain_len)
      let dot_found = find_char_pos(domain, '.')
      match dot_found {
        None => invalid("email domain must contain a '.'")
        Some(dp) => {
          if dp == 0 {
            invalid("email domain must not start with '.'")
          } else if dp == domain.length() - 1 {
            invalid("email domain must not end with '.'")
          } else {
            valid()
          }
        }
      }
    }
  }
}

///|
/// Validate a URL with basic format check.
pub fn validate_url(value : String) -> ValidationResult {
  if value.length() == 0 {
    return invalid("URL must not be empty")
  }

  let lower = value.to_lower()

  if lower.starts_with("http://") || lower.starts_with("https://") {
    let host_start = if lower.starts_with("https://") { 8 } else { 7 }
    if host_start >= value.length() {
      invalid("URL host must not be empty")
    } else {
      valid()
    }
  } else {
    invalid("URL must start with http:// or https://")
  }
}

///|
/// Validate that a string contains only alphanumeric characters.
pub fn validate_alphanumeric(value : String, field_name : String) -> ValidationResult {
  if value.length() == 0 {
    return invalid("\{field_name} must not be empty")
  }
  for ch in value {
    if !(ch.is_ascii_alphabetic() || ch.is_digit(10U)) {
      return invalid("\{field_name} must contain only letters and digits")
    }
  }
  valid()
}

///|
/// Validate that a string contains a substring.
pub fn validate_contains(
  value : String,
  substring : String,
  field_name : String,
) -> ValidationResult {
  if value.contains(substring) {
    valid()
  } else {
    invalid("\{field_name} must contain '\{substring}'")
  }
}

///|
/// Validate that a string does not contain a substring.
pub fn validate_not_contains(
  value : String,
  substring : String,
  field_name : String,
) -> ValidationResult {
  if value.contains(substring) {
    invalid("\{field_name} must not contain '\{substring}'")
  } else {
    valid()
  }
}

///|
/// Find the position of a character in a string.
fn find_char_pos(s : String, target : Char) -> Int? {
  let mut idx = 0
  for ch in s {
    if ch == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}
