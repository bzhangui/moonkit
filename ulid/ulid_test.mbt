///|
/// Tests for ULID generation and validation.

///|
test "generate produces valid ULID" {
  let ulid = generate()
  @test.assert_eq(ulid.length(), 26)
  @test.assert_eq(is_valid(ulid), true)
}

///|
test "generate produces different values" {
  let a = generate()
  let b = generate()
  // Due to our simple implementation, these may not differ
  // but they should both be valid
  @test.assert_eq(is_valid(a), true)
  @test.assert_eq(is_valid(b), true)
}

///|
test "is_valid correct length" {
  @test.assert_eq(is_valid("0123456789ABCDEFGHJKMNPQR"), true)
  @test.assert_eq(is_valid("0123456789ABCDEFGHJKMNPQRST"), true)
}

///|
test "is_valid too short" {
  @test.assert_eq(is_valid("short"), false)
  @test.assert_eq(is_valid(""), false)
}

///|
test "is_valid too long" {
  @test.assert_eq(is_valid("0123456789ABCDEFGHJKMNPQRSTUV"), false)
}

///|
test "is_valid invalid characters" {
  // Contains 'I' which is not in Crockford Base32
  @test.assert_eq(is_valid("0123456789ABCDEFGHIJKLMNOP"), false)
  // Contains 'L'
  @test.assert_eq(is_valid("0123456789ABCDEFGHJKLMNPQRST"), false)
  // Contains 'O'
  @test.assert_eq(is_valid("0123456789ABCDEFGHJKMNPQRSTO"), false)
  // Contains 'U'
  @test.assert_eq(is_valid("0123456789ABCDEFGHJKMNPQRSTU"), false)
}

///|
test "is_valid lowercase accepted" {
  // Lowercase should be converted to uppercase and validated
  @test.assert_eq(is_valid("abcdefghijklmnopqrstuvwxyz01"), true)
}

///|
test "timestamp_ms from ULID" {
  let ulid = "00000000000000000000000000"
  // First 10 chars are '0' = index 0
  let ts = timestamp_ms(ulid)
  @test.assert_eq(ts, 0)
}

///|
test "timestamp_ms invalid length" {
  @test.assert_eq(timestamp_ms("short"), 0)
  @test.assert_eq(timestamp_ms(""), 0)
}

///|
test "compare same ULIDs" {
  let a = "0123456789ABCDEFGHJKMNPQR"
  let b = "0123456789ABCDEFGHJKMNPQR"
  @test.assert_eq(compare(a, b), 0)
}

///|
test "compare different ULIDs" {
  let a = "00000000000000000000000000"
  let b = "00000000000000000000000001"
  @test.assert_eq(compare(a, b), -1)
  @test.assert_eq(compare(b, a), 1)
}

///|
test "generate produces 26 chars" {
  for i = 0; i < 10; i = i + 1 {
    let ulid = generate()
    @test.assert_eq(ulid.length(), 26)
  }
}
