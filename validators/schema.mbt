///|
/// Schema-based validation framework.

///|
/// A schema field definition.
pub(all) struct SchemaField {
  name : String
  label : String
  required : Bool
  min_len : Int?
  max_len : Int?
  kind : FieldKind
} derive(Debug)

///|
/// Field validation type.
pub(all) enum FieldKind {
  Any
  Email
  Url
  Alphanumeric
} derive(Debug)

///|
/// A validation schema.
pub(all) struct Schema {
  fields : Array[SchemaField]
} derive(Debug)

///|
/// Create a new empty schema.
pub fn Schema::new() -> Schema {
  { fields: [] }
}

///|
/// Add a text field.
pub fn add_text_field(
  schema : Schema,
  name : String,
  label : String,
  required~ : Bool = true,
  min_len~ : Int? = None,
  max_len~ : Int? = None,
) -> Unit {
  let field = {
    name,
    label,
    required,
    min_len,
    max_len,
    kind: Any,
  }
  schema.fields.push(field)
}

///|
/// Add an email field.
pub fn add_email_field(
  schema : Schema,
  name : String,
  label : String,
  required~ : Bool = true,
) -> Unit {
  let field = {
    name,
    label,
    required,
    min_len: None,
    max_len: None,
    kind: Email,
  }
  schema.fields.push(field)
}

///|
/// Add a URL field.
pub fn add_url_field(
  schema : Schema,
  name : String,
  label : String,
  required~ : Bool = true,
) -> Unit {
  let field = {
    name,
    label,
    required,
    min_len: None,
    max_len: None,
    kind: Url,
  }
  schema.fields.push(field)
}

///|
/// Validate a single field.
fn validate_field(field : SchemaField, value : String) -> Result[String, String] {
  match field.min_len {
    Some(min) => {
      if value.length() < min {
        return Err("\{field.label} must be at least \{min} characters")
      }
    }
    None => ()
  }

  match field.max_len {
    Some(max) => {
      if value.length() > max {
        return Err("\{field.label} must be at most \{max} characters")
      }
    }
    None => ()
  }

  match field.kind {
    Email => {
      match validate_email(value) {
        Ok(_) => ()
        Err(_) => return Err("\{field.label} must be a valid email address")
      }
    }
    Url => {
      match validate_url(value) {
        Ok(_) => ()
        Err(_) => return Err("\{field.label} must be a valid URL")
      }
    }
    Alphanumeric => {
      match validate_alphanumeric(value, field.label) {
        Ok(_) => ()
        Err(msg) => return Err(msg)
      }
    }
    Any => ()
  }

  Ok(value)
}

///|
/// Validate a map of values against the schema.
pub fn validate_schema(
  schema : Schema,
  values : Map[String, String],
) -> Result[Unit, String] {
  for field in schema.fields {
    match values.get(field.name) {
      Some(value) => {
        match validate_field(field, value) {
          Err(msg) => return Err(msg)
          Ok(_) => ()
        }
      }
      None => {
        if field.required {
          return Err("\{field.label} is required")
        }
      }
    }
  }
  Ok(())
}
