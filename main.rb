require 'json'
require './parser'

table = JSON.parse($stdin.read, symbolize_names: true)
schema = table.dig(:Table, :StorageDescriptor, :Columns).map do |s|
  {
    name: s[:Name],
  }.merge(SchemaTransform.new.apply(SchemaParser.new.parse(s[:Type])))
end
puts schema.to_json
