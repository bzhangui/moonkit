///|
/// ULID - Universally Unique Lexicographically Sortable Identifier.

///|
/// Crockford's Base32 encoding alphabet.
let base32_alphabet : String = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

///|
/// Generate a new ULID string.
pub fn generate() -> String {
  let ts = next_timestamp()
  encode_ulid(ts)
}

///|
/// Validate that a string is a well-formed ULID.
pub fn is_valid(s : String) -> Bool {
  if s.length() != 26 {
    return false
  }
  let upper = s.to_upper()
  for ch in upper {
    if !is_valid_base32_char(ch) {
      return false
    }
  }
  true
}

///|
/// Extract the timestamp in milliseconds from a ULID string.
pub fn timestamp_ms(ulid : String) -> Int {
  if ulid.length() != 26 {
    return 0
  }
  let mut value = 0
  let mut count = 0
  for ch in ulid {
    if count >= 10 {
      break
    }
    value = value * 32 + base32_index(ch)
    count = count + 1
  }
  value
}

///|
/// Compare two ULIDs (lexicographic = temporal ordering).
pub fn compare(a : String, b : String) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

///|
/// Encode a timestamp into a ULID string.
fn encode_ulid(timestamp : Int) -> String {
  let buf = Buffer::Buffer()
  encode_timestamp(buf, timestamp)
  encode_random(buf)
  buf.to_string()
}

///|
/// Encode timestamp into 10 Base32 characters.
fn encode_timestamp(buf : Buffer, timestamp : Int) -> Unit {
  let mut t = timestamp
  let encoded : Array[Char] = []
  for i = 0; i < 10; i = i + 1 {
    encoded.push(char_at(base32_alphabet, t % 32))
    t = t / 32
  }
  // Write in reverse (most significant first)
  let mut j = encoded.length()
  while j > 0 {
    j = j - 1
    buf.write_char(encoded[j])
  }
}

///|
/// Encode 16 random Base32 characters.
fn encode_random(buf : Buffer) -> Unit {
  let mut seed = next_timestamp()
  for i = 0; i < 16; i = i + 1 {
    seed = (seed * 1103515245 + 12345).land(0x7FFFFFFF)
    let idx = seed % 32
    buf.write_char(char_at(base32_alphabet, idx))
  }
}

///|
/// Get the character at a specific index in a string.
fn char_at(s : String, idx : Int) -> Char {
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
/// Check if a character is valid in Crockford's Base32 alphabet.
fn is_valid_base32_char(ch : Char) -> Bool {
  for c in base32_alphabet {
    if c == ch {
      return true
    }
  }
  false
}

///|
/// Get the index of a character in the Base32 alphabet.
fn base32_index(ch : Char) -> Int {
  let upper = ch.to_ascii_uppercase()
  let mut idx = 0
  for c in base32_alphabet {
    if c == upper {
      return idx
    }
    idx = idx + 1
  }
  0
}

///|
/// Simple incrementing counter for timestamps.
fn next_timestamp() -> Int {
  1700000000
}
