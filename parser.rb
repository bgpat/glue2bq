require 'parslet'

class SchemaParser < Parslet::Parser
  root(:schema)

  rule(:schema) {
    array | struct | primitive
  }

  rule(:primitive) {
    token.as(:type)
  }

  rule(:array) {
    str('array<') >> schema.as(:array) >> str('>')
  }

  rule(:struct) {
    str('struct<') >> (field.as(:field) >> str(',').maybe).repeat.as(:record) >> str('>')
  }

  rule(:field) {
    token.as(:name) >> str(':') >> schema.as(:schema)
  }

  rule(:token) {
    match(/\w/).repeat
  }
end

class SchemaTransform < Parslet::Transform
  rule(array: subtree(:l)) {
    l.merge({ mode: 'REPEATED' })
  }

  rule(record: subtree(:r)) {
    { type: 'RECORD', mode: 'NULLABLE', fields: r }
  }

  rule(field: subtree(:f)) {
    { name: f[:name].to_s }.merge(f[:schema])
  }

  rule(type: simple(:t)) {
    { type: t.to_s.upcase, mode: 'NULLABLE' }
  }
end
