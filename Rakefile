require "bundler/gem_tasks"

Bundler.setup :default, :development

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  case version = ENV['MONGO_VERSION'] || 'moped'
  when /^moped/
    require 'moped'
    spec.pattern = FileList['spec/**/moped_spec.rb']
  when /^mongo/
    require 'mongo'
    spec.pattern = FileList['spec/**/mongo_spec.rb']
  else
    fail "Invalid MONGO_VERSION: #{ENV['MONGO_VERSION']}."
  end
end

task default: [:spec]
