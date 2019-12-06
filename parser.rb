require 'parslet'

class SchemaParser < Parslet::Parser
  root(:schema)

  rule(:schema) {
    array | struct | primitive
  }

  rule(:primitive) {
    integer.as(:integer) | float.as(:float) | token.as(:type)
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

  rule(:integer) {
    str('int') | str('bigint')
  }

  rule(:float) {
    str('float') | str('double')
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

  rule(integer: simple(:t)) {
    { type: 'INTEGER', mode: 'NULLABLE' }
  }


  rule(float: simple(:t)) {
    { type: 'FLOAT', mode: 'NULLABLE' }
  }
end
