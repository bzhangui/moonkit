///|
/// Semantic Versioning comparison functions.

///|
/// Ordering result for version comparison.
pub(all) enum Ordering {
  Less
  Equal
  Greater
} derive(Debug, Eq)

///|
/// Compare two semantic versions by precedence rules.
/// Build metadata does NOT affect precedence.
pub fn compare(v1 : SemVer, v2 : SemVer) -> Ordering {
  if v1.major() < v2.major() {
    return Less
  }
  if v1.major() > v2.major() {
    return Greater
  }

  if v1.minor() < v2.minor() {
    return Less
  }
  if v1.minor() > v2.minor() {
    return Greater
  }

  if v1.patch() < v2.patch() {
    return Less
  }
  if v1.patch() > v2.patch() {
    return Greater
  }

  let pre1 = v1.prerelease()
  let pre2 = v2.prerelease()

  if pre1.length() == 0 && pre2.length() > 0 {
    return Greater
  }
  if pre1.length() > 0 && pre2.length() == 0 {
    return Less
  }

  let min_len = if pre1.length() < pre2.length() { pre1.length() } else { pre2.length() }
  for i = 0; i < min_len; i = i + 1 {
    let cmp = compare_identifier(pre1[i], pre2[i])
    match cmp {
      Equal => ()
      _ => return cmp
    }
  }

  if pre1.length() < pre2.length() {
    Less
  } else if pre1.length() > pre2.length() {
    Greater
  } else {
    Equal
  }
}

///|
/// Compare two prerelease/build identifiers.
fn compare_identifier(a : String, b : String) -> Ordering {
  let a_is_num = is_numeric(a)
  let b_is_num = is_numeric(b)

  if a_is_num && b_is_num {
    let na = parse_int(a)
    let nb = parse_int(b)
    if na < nb {
      Less
    } else if na > nb {
      Greater
    } else {
      Equal
    }
  } else if a_is_num {
    Less
  } else if b_is_num {
    Greater
  } else {
    if a < b {
      Less
    } else if a > b {
      Greater
    } else {
      Equal
    }
  }
}

///|
/// Check if a string is purely numeric.
fn is_numeric(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  for ch in s {
    if !ch.is_digit(10U) {
      return false
    }
  }
  true
}

///|
/// Parse an integer from a string (assumes valid input).
fn parse_int(s : String) -> Int {
  let mut value = 0
  for ch in s {
    value = value * 10 + (ch.to_int() - '0'.to_int())
  }
  value
}

///|
/// Check if v1 is less than v2.
pub fn less_than(v1 : SemVer, v2 : SemVer) -> Bool {
  match compare(v1, v2) {
    Less => true
    _ => false
  }
}

///|
/// Check if v1 is greater than v2.
pub fn greater_than(v1 : SemVer, v2 : SemVer) -> Bool {
  match compare(v1, v2) {
    Greater => true
    _ => false
  }
}

///|
/// Check if two versions are equal (ignoring build metadata).
pub fn equal(v1 : SemVer, v2 : SemVer) -> Bool {
  match compare(v1, v2) {
    Equal => true
    _ => false
  }
}

///|
/// Check if v1 is less than or equal to v2.
pub fn less_or_equal(v1 : SemVer, v2 : SemVer) -> Bool {
  match compare(v1, v2) {
    Less | Equal => true
    _ => false
  }
}

///|
/// Check if v1 is greater than or equal to v2.
pub fn greater_or_equal(v1 : SemVer, v2 : SemVer) -> Bool {
  match compare(v1, v2) {
    Greater | Equal => true
    _ => false
  }
}

///|
/// Find the maximum of two versions.
pub fn max(v1 : SemVer, v2 : SemVer) -> SemVer {
  if greater_than(v1, v2) { v1 } else { v2 }
}

///|
/// Find the minimum of two versions.
pub fn min(v1 : SemVer, v2 : SemVer) -> SemVer {
  if less_than(v1, v2) { v1 } else { v2 }
}

///|
/// Sort an array of versions in ascending order (in-place).
pub fn sort(versions : Array[SemVer]) -> Unit {
  let n = versions.length()
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n - i - 1; j = j + 1 {
      if greater_than(versions[j], versions[j + 1]) {
        let temp = versions[j]
        versions[j] = versions[j + 1]
        versions[j + 1] = temp
      }
    }
  }
}

///|
/// Get the latest (highest) version from an array.
pub fn latest(versions : Array[SemVer]) -> SemVer? {
  if versions.length() == 0 {
    return None
  }
  let mut best = versions[0]
  for i = 1; i < versions.length(); i = i + 1 {
    if greater_than(versions[i], best) {
      best = versions[i]
    }
  }
  Some(best)
}
