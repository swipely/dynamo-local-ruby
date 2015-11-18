# encoding: utf-8
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

dynamodb_local_path = File.expand_path('../lib/jars/dynamodb_local', __FILE__)
dynamodb_local_tgz  = 'dynamodb_local_latest.tar.gz'
dynamodb_local_source_pkg = File.join(dynamodb_local_path, dynamodb_local_tgz)

directory dynamodb_local_path

file dynamodb_local_source_pkg => dynamodb_local_path do |task|
  s3_url = 'http://dynamodb-local.s3-website-us-west-2.amazonaws.com'
  `wget #{s3_url}/#{dynamodb_local_tgz} -O #{task.name}`
end

task unpack_source_pkg: [
  dynamodb_local_source_pkg,
  dynamodb_local_path
] do |task|
  `tar xzf #{task.source} -C #{task.sources.last}`
end

task remove_source_pkg: dynamodb_local_source_pkg do |task|
  rm task.source
end

task default: [:spec, :rubocop]

task build: [:unpack_source_pkg, :remove_source_pkg]
