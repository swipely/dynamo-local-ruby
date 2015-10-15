# encoding: utf-8
require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new
LATEST_WEB_TGZ = 'http://dynamodb-local.s3-website-us-west-2.amazonaws.com'\
                   '/dynamodb_local_latest.tar.gz'
JAR_NAME = 'DynamoDBLocal.jar'
LOCAL_JAR_DIR = '../lib/jars/dynamodb_local'
SPEC_JAR_DIR = File.expand_path('./spec/dynamo-local-ruby/support/jars/')
SPEC_JAR_FILE = File.join(SPEC_JAR_DIR, JAR_NAME)

task :download_dynamodb_local do
  local_path = File.expand_path(LOCAL_JAR_DIR, __FILE__)
  `mkdir -p #{local_path}`
  if File.exist?(File.join(local_path, JAR_NAME)) &&
     File.exist?(SPEC_JAR_FILE)
    copy_jar_to_specs(local_path, SPEC_JAR_DIR)
  else
    download_jar(local_path)
    copy_jar_to_specs(local_path, SPEC_JAR_DIR)
  end
end

task default: %w(spec rubocop)

task build: :download_dynamodb_local

def download_jar(local_path)
  latest = File.join(local_path, 'dynamodb_local_latest.tar.gz')
  `wget #{LATEST_WEB_TGZ} -O #{latest}` unless File.exist?(latest)
  `tar xzf #{latest} -C #{local_path}`
  `rm #{latest}` if File.exist?(latest)
end

def copy_jar_to_specs(local_path, spec_path)
  `cp -R #{local_path} #{spec_path}`
end
