///|
/// Tests for string case conversion utilities.

///|
test "to_camel basic" {
  @test.assert_eq(to_camel("hello_world"), "helloWorld")
  @test.assert_eq(to_camel("hello-world"), "helloWorld")
  @test.assert_eq(to_camel("hello world"), "helloWorld")
}

///|
test "to_camel from PascalCase" {
  @test.assert_eq(to_camel("HelloWorld"), "helloWorld")
  @test.assert_eq(to_camel("Hello"), "hello")
}

///|
test "to_camel from uppercase" {
  @test.assert_eq(to_camel("HELLO_WORLD"), "helloWorld")
}

///|
test "to_camel empty string" {
  @test.assert_eq(to_camel(""), "")
}

///|
test "to_camel single word" {
  @test.assert_eq(to_camel("hello"), "hello")
  @test.assert_eq(to_camel("Hello"), "hello")
  @test.assert_eq(to_camel("HELLO"), "hello")
}

///|
test "to_pascal basic" {
  @test.assert_eq(to_pascal("hello_world"), "HelloWorld")
  @test.assert_eq(to_pascal("hello-world"), "HelloWorld")
  @test.assert_eq(to_pascal("helloWorld"), "HelloWorld")
}

///|
test "to_pascal single word" {
  @test.assert_eq(to_pascal("hello"), "Hello")
}

///|
test "to_snake basic" {
  @test.assert_eq(to_snake("helloWorld"), "hello_world")
  @test.assert_eq(to_snake("HelloWorld"), "hello_world")
  @test.assert_eq(to_snake("hello-world"), "hello_world")
}

///|
test "to_snake from uppercase" {
  @test.assert_eq(to_snake("HELLO_WORLD"), "hello_world")
}

///|
test "to_snake simple cases" {
  @test.assert_eq(to_snake("hello"), "hello")
  @test.assert_eq(to_snake("HELLO"), "hello")
}

///|
test "to_upper_snake" {
  @test.assert_eq(to_upper_snake("helloWorld"), "HELLO_WORLD")
  @test.assert_eq(to_upper_snake("HelloWorld"), "HELLO_WORLD")
  @test.assert_eq(to_upper_snake("hello_world"), "HELLO_WORLD")
}

///|
test "to_kebab" {
  @test.assert_eq(to_kebab("helloWorld"), "hello-world")
  @test.assert_eq(to_kebab("HelloWorld"), "hello-world")
  @test.assert_eq(to_kebab("hello_world"), "hello-world")
  @test.assert_eq(to_kebab("Hello World"), "hello-world")
}

///|
test "to_title" {
  @test.assert_eq(to_title("hello_world"), "Hello World")
  @test.assert_eq(to_title("helloWorld"), "Hello World")
}

///|
test "is_camel valid" {
  @test.assert_eq(is_camel("helloWorld"), true)
  @test.assert_eq(is_camel("hello"), true)
  @test.assert_eq(is_camel("helloWorldTest"), true)
}

///|
test "is_camel invalid" {
  @test.assert_eq(is_camel("HelloWorld"), false)
  @test.assert_eq(is_camel("hello_world"), false)
  @test.assert_eq(is_camel(""), false)
  @test.assert_eq(is_camel("hello-world"), false)
}

///|
test "is_snake valid" {
  @test.assert_eq(is_snake("hello_world"), true)
  @test.assert_eq(is_snake("hello"), true)
  @test.assert_eq(is_snake("hello_world_test"), true)
}

///|
test "is_snake invalid" {
  @test.assert_eq(is_snake("helloWorld"), false)
  @test.assert_eq(is_snake("Hello_World"), false)
  @test.assert_eq(is_snake("hello-world"), false)
}

///|
test "roundtrip conversions" {
  // camelCase -> snake_case -> camelCase
  let original = "helloWorldTest"
  let snake = to_snake(original)
  @test.assert_eq(snake, "hello_world_test")
  @test.assert_eq(to_camel(snake), original)
}

///|
test "complex name with digits" {
  @test.assert_eq(to_camel("test_123_name"), "test123Name")
  @test.assert_eq(to_snake("test123Name"), "test123_name")
}

///|
test "multiple consecutive delimiters" {
  @test.assert_eq(to_camel("hello__world"), "helloWorld")
  @test.assert_eq(to_camel("hello--world"), "helloWorld")
}

///|
test "mixed separators" {
  @test.assert_eq(to_camel("hello_world-test"), "helloWorldTest")
  @test.assert_eq(to_snake("helloWorld-test"), "hello_world_test")
}

///|
test "acronyms in pascal" {
  @test.assert_eq(to_camel("HTTPS_URL"), "httpsUrl")
  @test.assert_eq(to_snake("HTTPSURL"), "httpsurl")
}

///|
test "title case" {
  @test.assert_eq(to_title("hello_world"), "Hello World")
  @test.assert_eq(to_title("helloWorld"), "Hello World")
  @test.assert_eq(to_title("hello-world"), "Hello World")
}
