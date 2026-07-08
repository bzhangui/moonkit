///|
/// Tests for SemVer comparison.

///|
test "equal versions" {
  let v1 = parse_result("1.0.0")
  let v2 = parse_result("1.0.0")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(equal(a, b), true)
      @test.assert_eq(less_than(a, b), false)
      @test.assert_eq(greater_than(a, b), false)
      @test.assert_eq(less_or_equal(a, b), true)
      @test.assert_eq(greater_or_equal(a, b), true)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "major version difference" {
  let v1 = parse_result("1.0.0")
  let v2 = parse_result("2.0.0")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(less_than(a, b), true)
      @test.assert_eq(greater_than(a, b), false)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "minor version difference" {
  let v1 = parse_result("1.1.0")
  let v2 = parse_result("1.2.0")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(less_than(a, b), true)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "patch version difference" {
  let v1 = parse_result("1.0.0")
  let v2 = parse_result("1.0.1")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(less_than(a, b), true)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "prerelease has lower precedence" {
  let v1 = parse_result("1.0.0-alpha")
  let v2 = parse_result("1.0.0")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(less_than(a, b), true)
      @test.assert_eq(greater_than(a, b), false)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "build metadata does not affect precedence" {
  let v1 = parse_result("1.0.0+build.1")
  let v2 = parse_result("1.0.0+build.2")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(equal(a, b), true)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "prerelease identifier comparison" {
  let alpha = parse_result("1.0.0-alpha")
  let beta = parse_result("1.0.0-beta")
  match (alpha, beta) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(less_than(a, b), true)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "numeric prerelease vs alphanumeric" {
  let v1 = parse_result("1.0.0-1")
  let v2 = parse_result("1.0.0-alpha")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      // Numeric identifiers have lower precedence
      @test.assert_eq(less_than(a, b), true)
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "max and min functions" {
  let v1 = parse_result("1.0.0")
  let v2 = parse_result("2.0.0")
  let v3 = parse_result("0.5.0")
  match (v1, v2, v3) {
    (Ok(a), Ok(b), Ok(c)) => {
      @test.assert_eq(max(a, b).to_string(), "2.0.0")
      @test.assert_eq(min(a, b).to_string(), "1.0.0")
      @test.assert_eq(min(a, c).to_string(), "0.5.0")
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "sort versions" {
  let v1 = parse_result("3.0.0")
  let v2 = parse_result("1.0.0")
  let v3 = parse_result("2.0.0")
  match (v1, v2, v3) {
    (Ok(a), Ok(b), Ok(c)) => {
      let arr = [a, b, c]
      sort(arr)
      @test.assert_eq(arr[0].to_string(), "1.0.0")
      @test.assert_eq(arr[1].to_string(), "2.0.0")
      @test.assert_eq(arr[2].to_string(), "3.0.0")
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "latest version" {
  let v1 = parse_result("1.0.0")
  let v2 = parse_result("1.2.0")
  let v3 = parse_result("1.0.5")
  match (v1, v2, v3) {
    (Ok(a), Ok(b), Ok(c)) => {
      match latest([a, b, c]) {
        Some(v) => @test.assert_eq(v.to_string(), "1.2.0")
        None => @test.fail("Expected Some")
      }
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "latest empty array" {
  let empty : Array[SemVer] = []
  match latest(empty) {
    Some(_) => @test.fail("Expected None")
    None => ()
  }
}

///|
test "compare returns ordering" {
  let v1 = parse_result("1.0.0")
  let v2 = parse_result("1.0.0")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      match compare(a, b) {
        Equal => ()
        _ => @test.fail("Expected Equal")
      }
    }
    _ => @test.fail("Parse failed")
  }
}

///|
test "longer prerelease has higher precedence if prefix matches" {
  let v1 = parse_result("1.0.0-alpha.1")
  let v2 = parse_result("1.0.0-alpha.1.1")
  match (v1, v2) {
    (Ok(a), Ok(b)) => {
      @test.assert_eq(less_than(a, b), true)
    }
    _ => @test.fail("Parse failed")
  }
}
