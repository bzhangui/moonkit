///|
/// Tests for TOML types and utilities.

///|
test "create string value" {
  let v = string("hello")
  @test.assert_eq(is_string(v), true)
  @test.assert_eq(is_integer(v), false)
  match get_string(v) {
    Some(s) => @test.assert_eq(s, "hello")
    None => @test.fail("Expected string")
  }
}

///|
test "create integer value" {
  let v = integer(42L)
  @test.assert_eq(is_integer(v), true)
  match get_integer(v) {
    Some(i) => @test.assert_eq(i, 42L)
    None => @test.fail("Expected integer")
  }
}

///|
test "create float value" {
  let v = float(3.14)
  @test.assert_eq(is_float(v), true)
  match get_float(v) {
    Some(f) => @test.assert_eq(f, 3.14)
    None => @test.fail("Expected float")
  }
}

///|
test "create boolean value" {
  let v = boolean(true)
  @test.assert_eq(is_boolean(v), true)
  match get_boolean(v) {
    Some(b) => @test.assert_eq(b, true)
    None => @test.fail("Expected boolean")
  }
}

///|
test "create array value" {
  let arr = [string("a"), string("b"), integer(1L)]
  let v = array(arr)
  @test.assert_eq(is_array(v), true)
  match get_array(v) {
    Some(a) => @test.assert_eq(a.length(), 3)
    None => @test.fail("Expected array")
  }
}

///|
test "create table value" {
  let t = Map::new()
  t.set("key", string("value"))
  let v = table(t)
  @test.assert_eq(is_table(v), true)
  match get_table(v) {
    Some(tbl) => {
      match tbl.get("key") {
        Some(TomlString(s)) => @test.assert_eq(s, "value")
        _ => @test.fail("Expected string value")
      }
    }
    None => @test.fail("Expected table")
  }
}

///|
test "empty document" {
  let doc = empty_document()
  // Empty document is just an empty map
  // No specific assertions needed beyond construction
}

///|
test "get_by_path simple key" {
  let t = Map::new()
  t.set("name", string("test"))
  match get_by_path(t, "name") {
    Some(TomlString(s)) => @test.assert_eq(s, "test")
    _ => @test.fail("Expected string")
  }
}

///|
test "get_by_path dotted key" {
  let inner = Map::new()
  inner.set("key", string("value"))
  let outer = Map::new()
  outer.set("section", TomlValue::TomlTable(inner))
  match get_by_path(outer, "section.key") {
    Some(TomlString(s)) => @test.assert_eq(s, "value")
    _ => @test.fail("Expected string")
  }
}

///|
test "get_by_path missing key" {
  let t = Map::new()
  t.set("name", string("test"))
  match get_by_path(t, "nonexistent") {
    None => ()
    Some(_) => @test.fail("Expected None")
  }
}

///|
test "get_by_path empty path" {
  let t = Map::new()
  match get_by_path(t, "") {
    None => ()
    Some(_) => @test.fail("Expected None")
  }
}

///|
test "insert_by_path simple key" {
  let t = Map::new()
  insert_by_path(t, "name", string("test"))
  match t.get("name") {
    Some(TomlString(s)) => @test.assert_eq(s, "test")
    _ => @test.fail("Expected string")
  }
}

///|
test "insert_by_path creates intermediate tables" {
  let t = Map::new()
  insert_by_path(t, "a.b.c", string("nested"))
  match t.get("a") {
    Some(TomlValue::TomlTable(a)) => {
      match a.get("b") {
        Some(TomlValue::TomlTable(b)) => {
          match b.get("c") {
            Some(TomlString(s)) => @test.assert_eq(s, "nested")
            _ => @test.fail("Expected string value")
          }
        }
        _ => @test.fail("Expected table b")
      }
    }
    _ => @test.fail("Expected table a")
  }
}

///|
test "insert_by_path empty path" {
  let t = Map::new()
  insert_by_path(t, "", string("test"))
  // Empty path should be a no-op
}

///|
test "type predicates" {
  @test.assert_eq(is_string(string("s")), true)
  @test.assert_eq(is_integer(integer(1L)), true)
  @test.assert_eq(is_float(float(1.0)), true)
  @test.assert_eq(is_boolean(boolean(true)), true)
  @test.assert_eq(is_array(array([])), true)
  @test.assert_eq(is_table(table(Map::new())), true)
}

///|
test "get_wrong_type returns none" {
  let v = string("hello")
  @test.assert_eq(get_integer(v), None)
  @test.assert_eq(get_float(v), None)
  @test.assert_eq(get_boolean(v), None)
  @test.assert_eq(get_array(v), None)
  @test.assert_eq(get_table(v), None)
}

///|
test "nested table traversal" {
  let t = Map::new()
  insert_by_path(t, "servers.alpha.ip", string("10.0.0.1"))
  insert_by_path(t, "servers.alpha.role", string("frontend"))
  insert_by_path(t, "servers.beta.ip", string("10.0.0.2"))

  match get_by_path(t, "servers.alpha.ip") {
    Some(TomlString(s)) => @test.assert_eq(s, "10.0.0.1")
    _ => @test.fail("Expected string")
  }

  match get_by_path(t, "servers.beta.ip") {
    Some(TomlString(s)) => @test.assert_eq(s, "10.0.0.2")
    _ => @test.fail("Expected string")
  }
}
