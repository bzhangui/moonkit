///|
/// Semantic Versioning 2.0.0 type definitions.
///
/// Compliant with the [SemVer 2.0.0 specification](https://semver.org/).

///|
/// A semantic version identifier.
pub(all) struct SemVer {
  major : Int
  minor : Int
  patch : Int
  prerelease : Array[String]
  build : Array[String]
} derive(Debug, Eq)

///|
/// Create a new SemVer instance.
pub fn SemVer::new(
  major~ : Int,
  minor~ : Int,
  patch~ : Int,
) -> SemVer {
  {
    major,
    minor,
    patch,
    prerelease: [],
    build: [],
  }
}

///|
/// Create a SemVer with prerelease identifiers.
pub fn SemVer::with_prerelease(
  self : SemVer,
  prerelease : Array[String],
) -> SemVer {
  { ..self, prerelease }
}

///|
/// Create a SemVer with build metadata.
pub fn SemVer::with_build(
  self : SemVer,
  build : Array[String],
) -> SemVer {
  { ..self, build }
}

///|
/// Get the major version.
pub fn SemVer::major(self : SemVer) -> Int {
  self.major
}

///|
/// Get the minor version.
pub fn SemVer::minor(self : SemVer) -> Int {
  self.minor
}

///|
/// Get the patch version.
pub fn SemVer::patch(self : SemVer) -> Int {
  self.patch
}

///|
/// Get the prerelease identifiers.
pub fn SemVer::prerelease(self : SemVer) -> Array[String] {
  self.prerelease
}

///|
/// Get the build metadata.
pub fn SemVer::build(self : SemVer) -> Array[String] {
  self.build
}

///|
/// Check if this is a prerelease version.
pub fn SemVer::is_prerelease(self : SemVer) -> Bool {
  self.prerelease.length() > 0
}

///|
/// Check if this version has build metadata.
pub fn SemVer::has_build(self : SemVer) -> Bool {
  self.build.length() > 0
}

///|
/// Convert to the standard string representation.
pub fn SemVer::to_string(self : SemVer) -> String {
  let buf = Buffer::Buffer()
  buf.write_string(self.major.to_string())
  buf.write_char('.')
  buf.write_string(self.minor.to_string())
  buf.write_char('.')
  buf.write_string(self.patch.to_string())
  if self.prerelease.length() > 0 {
    buf.write_char('-')
    for i = 0; i < self.prerelease.length(); i = i + 1 {
      if i > 0 {
        buf.write_char('.')
      }
      buf.write_string(self.prerelease[i])
    }
  }
  if self.build.length() > 0 {
    buf.write_char('+')
    for i = 0; i < self.build.length(); i = i + 1 {
      if i > 0 {
        buf.write_char('.')
      }
      buf.write_string(self.build[i])
    }
  }
  buf.to_string()
}
