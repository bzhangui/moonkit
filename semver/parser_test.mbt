///|
/// Tests for SemVer parser.

///|
test "parse simple version" {
  let v = parse_result("1.2.3")
  match v {
    Ok(sv) => {
      @test.assert_eq(sv.major(), 1)
      @test.assert_eq(sv.minor(), 2)
      @test.assert_eq(sv.patch(), 3)
      @test.assert_eq(sv.is_prerelease(), false)
      @test.assert_eq(sv.has_build(), false)
    }
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "parse version with prerelease" {
  let v = parse_result("1.0.0-alpha.1")
  match v {
    Ok(sv) => {
      @test.assert_eq(sv.major(), 1)
      @test.assert_eq(sv.minor(), 0)
      @test.assert_eq(sv.patch(), 0)
      @test.assert_eq(sv.is_prerelease(), true)
      @test.assert_eq(sv.prerelease().length(), 2)
      @test.assert_eq(sv.prerelease()[0], "alpha")
      @test.assert_eq(sv.prerelease()[1], "1")
    }
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "parse version with build metadata" {
  let v = parse_result("1.0.0+build.123")
  match v {
    Ok(sv) => {
      @test.assert_eq(sv.has_build(), true)
      @test.assert_eq(sv.build().length(), 2)
      @test.assert_eq(sv.build()[0], "build")
      @test.assert_eq(sv.build()[1], "123")
    }
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "parse version with prerelease and build" {
  let v = parse_result("2.0.0-rc.1+build.42")
  match v {
    Ok(sv) => {
      @test.assert_eq(sv.major(), 2)
      @test.assert_eq(sv.is_prerelease(), true)
      @test.assert_eq(sv.has_build(), true)
      @test.assert_eq(sv.prerelease()[0], "rc")
      @test.assert_eq(sv.build()[0], "build")
    }
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "parse empty string returns error" {
  let v = parse_result("")
  match v {
    Ok(_) => @test.fail("Expected error")
    Err(_) => ()
  }
}

///|
test "parse invalid format returns error" {
  let v = parse_result("not.a.version")
  match v {
    Ok(_) => @test.fail("Expected error")
    Err(_) => ()
  }
}

///|
test "parse major.minor only returns error" {
  let v = parse_result("1.2")
  match v {
    Ok(_) => @test.fail("Expected error")
    Err(_) => ()
  }
}

///|
test "to_string roundtrip" {
  let cases = ["1.0.0", "2.3.4-alpha", "0.1.0+build", "10.20.30-beta.1+exp.sha.5114f85"]
  for case in cases {
    match parse_result(case) {
      Ok(v) => @test.assert_eq(v.to_string(), case)
      Err(_) => @test.fail("Failed to parse: \{case}")
    }
  }
}

///|
test "parse zero version" {
  let v = parse_result("0.0.0")
  match v {
    Ok(sv) => {
      @test.assert_eq(sv.major(), 0)
      @test.assert_eq(sv.minor(), 0)
      @test.assert_eq(sv.patch(), 0)
    }
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "parse large version numbers" {
  let v = parse_result("999.999.999")
  match v {
    Ok(sv) => {
      @test.assert_eq(sv.major(), 999)
      @test.assert_eq(sv.minor(), 999)
      @test.assert_eq(sv.patch(), 999)
    }
    Err(_) => @test.fail("Expected Ok")
  }
}

///|
test "parse prerelease with multiple dots" {
  let v = parse_result("1.0.0-alpha.beta.1.2.3")
  match v {
    Ok(sv) => {
      @test.assert_eq(sv.prerelease().length(), 5)
      @test.assert_eq(sv.prerelease()[4], "3")
    }
    Err(_) => @test.fail("Expected Ok")
  }
}
