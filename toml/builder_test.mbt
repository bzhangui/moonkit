///|
/// Tests for TOML document builder.

///|
test "builder set string" {
  let builder = TomlBuilder::new()
  let builder = builder.set_string("name", "test")
  let doc = builder.build()
  match doc.get("name") {
    Some(TomlValue::TomlString(s)) => @test.assert_eq(s, "test")
    _ => @test.fail("Expected string value")
  }
}

///|
test "builder set integer" {
  let builder = TomlBuilder::new()
  let builder = builder.set_integer("count", 42L)
  let doc = builder.build()
  match doc.get("count") {
    Some(TomlValue::TomlInteger(i)) => @test.assert_eq(i, 42L)
    _ => @test.fail("Expected integer value")
  }
}

///|
test "builder set float" {
  let builder = TomlBuilder::new()
  let builder = builder.set_float("pi", 3.14)
  let doc = builder.build()
  match doc.get("pi") {
    Some(TomlValue::TomlFloat(f)) => @test.assert_eq(f, 3.14)
    _ => @test.fail("Expected float value")
  }
}

///|
test "builder set boolean" {
  let builder = TomlBuilder::new()
  let builder = builder.set_boolean("enabled", true)
  let doc = builder.build()
  match doc.get("enabled") {
    Some(TomlValue::TomlBoolean(b)) => @test.assert_eq(b, true)
    _ => @test.fail("Expected boolean value")
  }
}

///|
test "builder table section" {
  let builder = TomlBuilder::new()
  let builder = builder.set_string("title", "Config")
  let inner = builder.table("server")
  let inner = inner.set_string("host", "localhost")
  let inner = inner.set_integer("port", 8080L)
  let back = inner.end_table()
  let doc = back.build()

  match doc.get("title") {
    Some(TomlValue::TomlString(s)) => @test.assert_eq(s, "Config")
    _ => @test.fail("Expected title")
  }

  match doc.get("server") {
    Some(TomlValue::TomlTable(t)) => {
      match t.get("host") {
        Some(TomlValue::TomlString(h)) => @test.assert_eq(h, "localhost")
        _ => @test.fail("Expected host")
      }
      match t.get("port") {
        Some(TomlValue::TomlInteger(p)) => @test.assert_eq(p, 8080L)
        _ => @test.fail("Expected port")
      }
    }
    _ => @test.fail("Expected table")
  }
}

///|
test "builder nested tables" {
  let builder = TomlBuilder::new()
  let l1 = builder.table("level1")
  let l2 = l1.table("level2")
  let l2 = l2.set_string("key", "deep_value")
  let doc = l2.end_table().end_table().build()

  match doc.get("level1") {
    Some(TomlValue::TomlTable(t1)) => {
      match t1.get("level2") {
        Some(TomlValue::TomlTable(t2)) => {
          match t2.get("key") {
            Some(TomlValue::TomlString(s)) => @test.assert_eq(s, "deep_value")
            _ => @test.fail("Expected key")
          }
        }
        _ => @test.fail("Expected level2 table")
      }
    }
    _ => @test.fail("Expected level1 table")
  }
}

///|
test "simple_doc convenience" {
  let pairs = [
    pair_string("name", "test"),
    pair_integer("version", 1L),
    pair_boolean("active", true),
  ]
  let doc = simple_doc(pairs)
  match doc.get("name") {
    Some(TomlValue::TomlString(s)) => @test.assert_eq(s, "test")
    _ => @test.fail("Expected name")
  }
  match doc.get("version") {
    Some(TomlValue::TomlInteger(v)) => @test.assert_eq(v, 1L)
    _ => @test.fail("Expected version")
  }
}

///|
test "builder set array" {
  let builder = TomlBuilder::new()
  let arr = [TomlValue::TomlString("a"), TomlValue::TomlString("b"), TomlValue::TomlString("c")]
  let builder = builder.set_array("items", arr)
  let doc = builder.build()
  match doc.get("items") {
    Some(TomlValue::TomlArray(a)) => @test.assert_eq(a.length(), 3)
    _ => @test.fail("Expected array")
  }
}

///|
test "builder chained calls" {
  let builder = TomlBuilder::new()
  let builder = builder.set_string("a", "1").set_string("b", "2").set_string("c", "3")
  let doc = builder.build()
  // Verify keys exist
  match doc.get("a") {
    Some(_) => ()
    _ => @test.fail("Expected key 'a'")
  }
}

///|
test "builder multiple values" {
  let builder = TomlBuilder::new()
  let builder = builder.set_string("name", "config")
  let builder = builder.set_integer("port", 3000L)
  let builder = builder.set_float("timeout", 30.0)
  let builder = builder.set_boolean("debug", false)
  let doc = builder.build()

  match doc.get("name") {
    Some(TomlValue::TomlString(_)) => ()
    _ => @test.fail("Expected name")
  }
  match doc.get("port") {
    Some(TomlValue::TomlInteger(_)) => ()
    _ => @test.fail("Expected port")
  }
  match doc.get("timeout") {
    Some(TomlValue::TomlFloat(_)) => ()
    _ => @test.fail("Expected timeout")
  }
  match doc.get("debug") {
    Some(TomlValue::TomlBoolean(_)) => ()
    _ => @test.fail("Expected debug")
  }
}
