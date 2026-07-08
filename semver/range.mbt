///|
/// Version range matching (basic implementation).
///
/// Supports simple version constraints like >=, >, <, <=, =, ^ and ~.

///|
/// A version constraint.
pub(all) enum Constraint {
  GreaterThan(SemVer)
  GreaterOrEqual(SemVer)
  LessThan(SemVer)
  LessOrEqual(SemVer)
  Exact(SemVer)
  Caret(SemVer)
  Tilde(SemVer)
} derive(Debug, Eq)

///|
/// Check if a version satisfies a constraint.
pub fn satisfies(v : SemVer, constraint : Constraint) -> Bool {
  match constraint {
    GreaterThan(c) => greater_than(v, c)
    GreaterOrEqual(c) => greater_or_equal(v, c)
    LessThan(c) => less_than(v, c)
    LessOrEqual(c) => less_or_equal(v, c)
    Exact(c) => equal(v, c)
    Caret(c) => satisfies_caret(v, c)
    Tilde(c) => satisfies_tilde(v, c)
  }
}

///|
/// Caret constraint (^): allows changes that do not modify the leftmost non-zero digit.
/// ^1.2.3 := >=1.2.3 <2.0.0
/// ^0.2.3 := >=0.2.3 <0.3.0
/// ^0.0.3 := >=0.0.3 <0.0.4
/// ^1.2.x := >=1.2.0 <2.0.0
/// ^0.0.x := >=0.0.0 <0.1.0
/// ^0.0   := >=0.0.0 <0.1.0
fn satisfies_caret(v : SemVer, constraint : SemVer) -> Bool {
  let major = constraint.major()
  let minor = constraint.minor()
  let patch = constraint.patch()

  let lower = constraint
  let upper = if major > 0 {
    SemVer::new(major=major + 1, minor=0, patch=0)
  } else if minor > 0 {
    SemVer::new(major=0, minor=minor + 1, patch=0)
  } else if patch > 0 {
    SemVer::new(major=0, minor=0, patch=patch + 1)
  } else {
    // ^0.0.0 - allow anything
    return true
  }

  greater_or_equal(v, lower) && less_than(v, upper)
}

///|
/// Tilde constraint (~): allows patch-level changes if minor is specified,
/// or minor-level changes if minor is not specified.
/// ~1.2.3 := >=1.2.3 <1.3.0
/// ~1.2   := >=1.2.0 <1.3.0
/// ~1     := >=1.0.0 <2.0.0
fn satisfies_tilde(v : SemVer, constraint : SemVer) -> Bool {
  let major = constraint.major()
  let minor = constraint.minor()
  let patch = constraint.patch()

  let lower = constraint
  let upper = SemVer::new(major=major, minor=minor + 1, patch=0)

  greater_or_equal(v, lower) && less_than(v, upper)
}

///|
/// Parse a version range string.
/// Supported formats:
/// - ">=1.2.3" - greater than or equal
/// - ">1.2.3" - greater than
/// - "<1.2.3" - less than
/// - "<=1.2.3" - less than or equal
/// - "=1.2.3" or "1.2.3" - exact
/// - "^1.2.3" - caret
/// - "~1.2.3" - tilde
pub fn parse_constraint(input : String) -> Constraint? {
  if input.length() == 0 {
    return None
  }

  let first = input[0]
  match first {
    '>' => {
      if input.length() > 1 && input[1] == '=' {
        let ver_str = input.substring(start=2)
        match parse_result(ver_str) {
          Ok(v) => Some(GreaterOrEqual(v))
          Err(_) => None
        }
      } else {
        let ver_str = input.substring(start=1)
        match parse_result(ver_str) {
          Ok(v) => Some(GreaterThan(v))
          Err(_) => None
        }
      }
    }
    '<' => {
      if input.length() > 1 && input[1] == '=' {
        let ver_str = input.substring(start=2)
        match parse_result(ver_str) {
          Ok(v) => Some(LessOrEqual(v))
          Err(_) => None
        }
      } else {
        let ver_str = input.substring(start=1)
        match parse_result(ver_str) {
          Ok(v) => Some(LessThan(v))
          Err(_) => None
        }
      }
    }
    '=' => {
      let ver_str = input.substring(start=1)
      match parse_result(ver_str) {
        Ok(v) => Some(Exact(v))
        Err(_) => None
      }
    }
    '^' => {
      let ver_str = input.substring(start=1)
      match parse_result(ver_str) {
        Ok(v) => Some(Caret(v))
        Err(_) => None
      }
    }
    '~' => {
      let ver_str = input.substring(start=1)
      match parse_result(ver_str) {
        Ok(v) => Some(Tilde(v))
        Err(_) => None
      }
    }
    _ => {
      // Exact version without prefix
      match parse_result(input) {
        Ok(v) => Some(Exact(v))
        Err(_) => None
      }
    }
  }
}

///|
/// Check if a version satisfies a version range string.
pub fn satisfies_str(v : SemVer, range : String) -> Bool {
  match parse_constraint(range) {
    Some(c) => satisfies(v, c)
    None => false
  }
}
