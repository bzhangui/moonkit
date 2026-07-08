///|
/// Tests for schema validation framework.

///|
test "schema required field missing" {
  let schema = Schema::new()
  add_text_field(schema, "name", "Name", min_len=Some(3))

  let values = Map::new()
  match validate_schema(schema, values) {
    Ok(_) => @test.fail("Expected error")
    Err(msg) => @test.assert_eq(msg.contains("required"), true)
  }
}

///|
test "schema required field present" {
  let schema = Schema::new()
  add_text_field(schema, "name", "Name", min_len=Some(3))

  let values = Map::new()
  values.set("name", "John")
  match validate_schema(schema, values) {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
}

///|
test "schema min length fail" {
  let schema = Schema::new()
  add_text_field(schema, "name", "Name", min_len=Some(10))

  let values = Map::new()
  values.set("name", "John")
  match validate_schema(schema, values) {
    Ok(_) => @test.fail("Expected error")
    Err(msg) => @test.assert_eq(msg.contains("at least"), true)
  }
}

///|
test "schema max length fail" {
  let schema = Schema::new()
  add_text_field(schema, "code", "Code", max_len=Some(3))

  let values = Map::new()
  values.set("code", "abcdefgh")
  match validate_schema(schema, values) {
    Ok(_) => @test.fail("Expected error")
    Err(msg) => @test.assert_eq(msg.contains("at most"), true)
  }
}

///|
test "schema email validation" {
  let schema = Schema::new()
  add_email_field(schema, "email", "Email Address")

  let values = Map::new()
  values.set("email", "user@example.com")
  match validate_schema(schema, values) {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
}

///|
test "schema email validation fail" {
  let schema = Schema::new()
  add_email_field(schema, "email", "Email Address")

  let values = Map::new()
  values.set("email", "not-an-email")
  match validate_schema(schema, values) {
    Ok(_) => @test.fail("Expected error")
    Err(_) => ()
  }
}

///|
test "schema optional field ok when missing" {
  let schema = Schema::new()
  add_email_field(schema, "email", "Email Address", required=false)

  let values = Map::new()
  values.set("name", "John")
  match validate_schema(schema, values) {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
}

///|
test "schema multiple fields" {
  let schema = Schema::new()
  add_text_field(schema, "username", "Username", min_len=Some(3), max_len=Some(50))
  add_email_field(schema, "email", "Email Address")
  add_text_field(schema, "password", "Password", min_len=Some(8))

  let values = Map::new()
  values.set("username", "johndoe")
  values.set("email", "john@example.com")
  values.set("password", "secure123")

  match validate_schema(schema, values) {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
}

///|
test "schema url field" {
  let schema = Schema::new()
  add_url_field(schema, "website", "Website")

  let values = Map::new()
  values.set("website", "https://example.com")
  match validate_schema(schema, values) {
    Ok(_) => ()
    Err(msg) => @test.fail(msg)
  }
}

///|
test "schema url field fail" {
  let schema = Schema::new()
  add_url_field(schema, "website", "Website")

  let values = Map::new()
  values.set("website", "not-a-url")
  match validate_schema(schema, values) {
    Ok(_) => @test.fail("Expected error")
    Err(_) => ()
  }
}
