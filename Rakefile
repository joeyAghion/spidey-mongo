require "bundler/gem_tasks"

Bundler.setup :default, :development

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList["spec/**/#{ENV['MONGO_VERSION']}_spec.rb"]
end

task default: [:spec]
