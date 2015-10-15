# encoding: utf-8
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'dynamo-local-ruby'
require 'rake'
require 'pry'

class DynamoLocalNotFound < StandardError; end

RSpec.configure do |config|
  config.order = 'random'

  config.before(:suite) do
    Rake.application.init
    Rake.application.load_rakefile

    rake_message = 'please run `rake download_dynamodb_local` to get latest'

    fail DynamoLocalNotFound, rake_message unless File.exist?(SPEC_JAR_FILE)

    unless File.exist?(File.expand_path(LOCAL_JAR_DIR, __FILE__))
      puts 'WARNING: You may not have the latest dynamo local jar'
      puts rake_message
    end
  end
end
