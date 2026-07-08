///|
/// Tests for data validators.

///|
test "validate_not_empty valid" {
  match validate_not_empty("hello", "name") {
    Ok(_) => ()
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "validate_not_empty invalid" {
  match validate_not_empty("", "name") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_length valid" {
  match validate_length("hello", 1, 10, "name") {
    Ok(_) => ()
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "validate_length too short" {
  match validate_length("ab", 3, 10, "name") {
    Ok(_) => @test.fail("Expected Err")
    Err(msg) => @test.assert_eq(msg.contains("at least"), true)
  }
}

///|
test "validate_length too long" {
  match validate_length("abcdefghij", 1, 5, "name") {
    Ok(_) => @test.fail("Expected Err")
    Err(msg) => @test.assert_eq(msg.contains("at most"), true)
  }
}

///|
test "validate_range valid" {
  match validate_range(5, 1, 10, "age") {
    Ok(_) => ()
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "validate_range too small" {
  match validate_range(0, 1, 10, "age") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_range too large" {
  match validate_range(100, 1, 10, "age") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_email valid" {
  match validate_email("user@example.com") {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
  match validate_email("test.user@sub.example.org") {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
}

///|
test "validate_email no at sign" {
  match validate_email("userexample.com") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_email empty local part" {
  match validate_email("@example.com") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_email empty domain" {
  match validate_email("user@") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_email no dot in domain" {
  match validate_email("user@example") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_email empty" {
  match validate_email("") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_email with spaces" {
  match validate_email("user @example.com") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_url valid" {
  match validate_url("https://example.com") {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
  match validate_url("http://example.com/path") {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
}

///|
test "validate_url invalid scheme" {
  match validate_url("ftp://example.com") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_url empty" {
  match validate_url("") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_alphanumeric valid" {
  match validate_alphanumeric("hello123", "username") {
    Ok(_) => ()
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "validate_alphanumeric with special chars" {
  match validate_alphanumeric("hello@123", "username") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_alphanumeric empty" {
  match validate_alphanumeric("", "username") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_contains valid" {
  match validate_contains("hello world", "world", "greeting") {
    Ok(_) => ()
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "validate_contains not found" {
  match validate_contains("hello", "x", "greeting") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}

///|
test "validate_not_contains valid" {
  match validate_not_contains("hello", "x", "greeting") {
    Ok(_) => ()
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "validate_not_contains found" {
  match validate_not_contains("hello world", "world", "greeting") {
    Ok(_) => @test.fail("Expected Err")
    Err(_) => ()
  }
}
