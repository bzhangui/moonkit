///|
/// Tests for version range matching.

///|
test "exact constraint satisfied" {
  let v = parse_result("1.2.3")
  match v {
    Ok(ver) => {
      let c = parse_constraint("=1.2.3")
      match c {
        Some(con) => @test.assert_eq(satisfies(ver, con), true)
        None => @test.fail("Failed to parse constraint")
      }
    }
    Err(_) => @test.fail("Failed to parse version")
  }
}

///|
test "exact constraint not satisfied" {
  let v = parse_result("1.2.4")
  match v {
    Ok(ver) => {
      let c = parse_constraint("=1.2.3")
      match c {
        Some(con) => @test.assert_eq(satisfies(ver, con), false)
        None => @test.fail("Failed to parse constraint")
      }
    }
    Err(_) => @test.fail("Failed to parse version")
  }
}

///|
test "caret constraint major > 0" {
  // ^1.2.3 allows >=1.2.3 <2.0.0
  let c = parse_constraint("^1.2.3")
  match c {
    Some(Caret(con)) => {
      let v1 = parse_result("1.2.3")
      let v2 = parse_result("1.5.0")
      let v3 = parse_result("1.9.9")
      let v4 = parse_result("2.0.0")
      let v5 = parse_result("0.9.0")
      match (v1, v2, v3, v4, v5) {
        (Ok(a), Ok(b), Ok(c), Ok(d), Ok(e)) => {
          @test.assert_eq(satisfies(a, Caret(con)), true)
          @test.assert_eq(satisfies(b, Caret(con)), true)
          @test.assert_eq(satisfies(c, Caret(con)), true)
          @test.assert_eq(satisfies(d, Caret(con)), false)
          @test.assert_eq(satisfies(e, Caret(con)), false)
        }
        _ => @test.fail("Parse failed")
      }
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "caret constraint minor = 0" {
  // ^0.2.3 allows >=0.2.3 <0.3.0
  let c = parse_constraint("^0.2.3")
  match c {
    Some(Caret(con)) => {
      let v1 = parse_result("0.2.3")
      let v2 = parse_result("0.2.9")
      let v3 = parse_result("0.3.0")
      match (v1, v2, v3) {
        (Ok(a), Ok(b), Ok(c)) => {
          @test.assert_eq(satisfies(a, Caret(con)), true)
          @test.assert_eq(satisfies(b, Caret(con)), true)
          @test.assert_eq(satisfies(c, Caret(con)), false)
        }
        _ => @test.fail("Parse failed")
      }
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "tilde constraint" {
  // ~1.2.3 allows >=1.2.3 <1.3.0
  let c = parse_constraint("~1.2.3")
  match c {
    Some(Tilde(con)) => {
      let v1 = parse_result("1.2.3")
      let v2 = parse_result("1.2.9")
      let v3 = parse_result("1.3.0")
      match (v1, v2, v3) {
        (Ok(a), Ok(b), Ok(c)) => {
          @test.assert_eq(satisfies(a, Tilde(con)), true)
          @test.assert_eq(satisfies(b, Tilde(con)), true)
          @test.assert_eq(satisfies(c, Tilde(con)), false)
        }
        _ => @test.fail("Parse failed")
      }
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "greater than constraint" {
  let c = parse_constraint(">1.0.0")
  match c {
    Some(GreaterThan(con)) => {
      let v1 = parse_result("1.0.1")
      let v2 = parse_result("1.0.0")
      match (v1, v2) {
        (Ok(a), Ok(b)) => {
          @test.assert_eq(satisfies(a, GreaterThan(con)), true)
          @test.assert_eq(satisfies(b, GreaterThan(con)), false)
        }
        _ => @test.fail("Parse failed")
      }
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "greater or equal constraint" {
  let c = parse_constraint(">=1.0.0")
  match c {
    Some(GreaterOrEqual(con)) => {
      let v1 = parse_result("1.0.0")
      let v2 = parse_result("0.9.0")
      match (v1, v2) {
        (Ok(a), Ok(b)) => {
          @test.assert_eq(satisfies(a, GreaterOrEqual(con)), true)
          @test.assert_eq(satisfies(b, GreaterOrEqual(con)), false)
        }
        _ => @test.fail("Parse failed")
      }
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "less than constraint" {
  let c = parse_constraint("<1.0.0")
  match c {
    Some(LessThan(con)) => {
      let v1 = parse_result("0.9.9")
      let v2 = parse_result("1.0.0")
      match (v1, v2) {
        (Ok(a), Ok(b)) => {
          @test.assert_eq(satisfies(a, LessThan(con)), true)
          @test.assert_eq(satisfies(b, LessThan(con)), false)
        }
        _ => @test.fail("Parse failed")
      }
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "less or equal constraint" {
  let c = parse_constraint("<=1.0.0")
  match c {
    Some(LessOrEqual(con)) => {
      let v1 = parse_result("1.0.0")
      let v2 = parse_result("1.0.1")
      match (v1, v2) {
        (Ok(a), Ok(b)) => {
          @test.assert_eq(satisfies(a, LessOrEqual(con)), true)
          @test.assert_eq(satisfies(b, LessOrEqual(con)), false)
        }
        _ => @test.fail("Parse failed")
      }
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "bare version exact match" {
  let c = parse_constraint("1.2.3")
  match c {
    Some(Exact(con)) => {
      @test.assert_eq(con.major(), 1)
      @test.assert_eq(con.minor(), 2)
      @test.assert_eq(con.patch(), 3)
    }
    _ => @test.fail("Failed to parse constraint")
  }
}

///|
test "invalid range string" {
  let c = parse_constraint("not-a-version")
  @test.assert_eq(c, None)
}

///|
test "satisfies_str convenience" {
  let v = parse_result("1.5.0")
  match v {
    Ok(ver) => {
      @test.assert_eq(satisfies_str(ver, ">=1.0.0"), true)
      @test.assert_eq(satisfies_str(ver, "<2.0.0"), true)
      @test.assert_eq(satisfies_str(ver, "^1.0.0"), true)
      @test.assert_eq(satisfies_str(ver, "<1.0.0"), false)
    }
    Err(_) => @test.fail("Parse failed")
  }
}
