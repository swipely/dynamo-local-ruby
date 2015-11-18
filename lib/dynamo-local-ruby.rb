# encoding: utf-8
require 'logger'

# DynamboLocalRuby
module DynamoLocalRuby
  LOG = Logger.new($stderr)
end

require 'dynamo-local-ruby/version'
require 'dynamo-local-ruby/dynamo_db_local'
require 'dynamo-local-ruby/dynamo_schema'
