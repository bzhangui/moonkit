///|
/// Tests for data conversion utilities.

///|
test "parse_bool truthy" {
  @test.assert_eq(parse_bool("true"), Some(true))
  @test.assert_eq(parse_bool("True"), Some(true))
  @test.assert_eq(parse_bool("TRUE"), Some(true))
  @test.assert_eq(parse_bool("1"), Some(true))
  @test.assert_eq(parse_bool("yes"), Some(true))
  @test.assert_eq(parse_bool("on"), Some(true))
}

///|
test "parse_bool falsy" {
  @test.assert_eq(parse_bool("false"), Some(false))
  @test.assert_eq(parse_bool("False"), Some(false))
  @test.assert_eq(parse_bool("0"), Some(false))
  @test.assert_eq(parse_bool("no"), Some(false))
  @test.assert_eq(parse_bool("off"), Some(false))
}

///|
test "parse_bool invalid" {
  @test.assert_eq(parse_bool(""), None)
  @test.assert_eq(parse_bool("maybe"), None)
  @test.assert_eq(parse_bool("2"), None)
}

///|
test "format_with_separator" {
  @test.assert_eq(format_with_separator(1000), "1,000")
  @test.assert_eq(format_with_separator(123), "123")
  @test.assert_eq(format_with_separator(12), "12")
}

///|
test "truncate" {
  @test.assert_eq(truncate("hello world", 20), "hello world")
  @test.assert_eq(truncate("hello world", 8), "hello...")
}

///|
test "pad_left" {
  @test.assert_eq(pad_left("42", 5, '0'), "00042")
  @test.assert_eq(pad_left("hello", 3, ' '), "hello")
}

///|
test "pad_right" {
  @test.assert_eq(pad_right("42", 5, ' '), "42   ")
  @test.assert_eq(pad_right("hello", 3, '-'), "hello")
}

///|
test "join" {
  @test.assert_eq(join(["a", "b", "c"], ", "), "a, b, c")
  @test.assert_eq(join(["hello"], ", "), "hello")
  @test.assert_eq(join([], ", "), "")
}

///|
test "repeat" {
  @test.assert_eq(repeat("ab", 3), "ababab")
  @test.assert_eq(repeat("x", 0), "")
  @test.assert_eq(repeat("", 5), "")
}

///|
test "reverse" {
  @test.assert_eq(reverse("hello"), "olleh")
  @test.assert_eq(reverse(""), "")
  @test.assert_eq(reverse("a"), "a")
}

///|
test "count_char" {
  @test.assert_eq(count_char("hello", 'l'), 2)
  @test.assert_eq(count_char("hello", 'x'), 0)
  @test.assert_eq(count_char("", 'a'), 0)
}

///|
test "is_int_string" {
  @test.assert_eq(is_int_string("123"), true)
  @test.assert_eq(is_int_string("-456"), true)
  @test.assert_eq(is_int_string(""), false)
  @test.assert_eq(is_int_string("abc"), false)
}

///|
test "is_float_string" {
  @test.assert_eq(is_float_string("3.14"), true)
  @test.assert_eq(is_float_string("-0.5"), true)
  @test.assert_eq(is_float_string("42"), true)
  @test.assert_eq(is_float_string(""), false)
  @test.assert_eq(is_float_string("."), false)
}

///|
test "format_with_separator large number" {
  @test.assert_eq(format_with_separator(1000000), "1,000,000")
  @test.assert_eq(format_with_separator(0), "0")
}

///|
test "truncate edge cases" {
  @test.assert_eq(truncate("hello world", 3), "hel")
  @test.assert_eq(truncate("a", 0), "")
}

///|
test "pad_left with char" {
  @test.assert_eq(pad_left("test", 8, '-'), "----test")
}

///|
test "pad_right with char" {
  @test.assert_eq(pad_right("test", 8, '.'), "test....")
}

///|
test "join with empty delimiter" {
  @test.assert_eq(join(["a", "b"], ""), "ab")
}

///|
test "reverse palindrome" {
  @test.assert_eq(reverse("racecar"), "racecar")
}

///|
test "count_char multiple" {
  @test.assert_eq(count_char("mississippi", 's'), 4)
  @test.assert_eq(count_char("mississippi", 'i'), 4)
}

///|
test "is_int_string with plus" {
  @test.assert_eq(is_int_string("+123"), true)
  @test.assert_eq(is_int_string("-0"), true)
}

///|
test "is_float_string edge cases" {
  @test.assert_eq(is_float_string("+3.14"), true)
  @test.assert_eq(is_float_string("-.5"), true)
  @test.assert_eq(is_float_string("abc"), false)
}
