$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

case version = ENV['MONGO_VERSION'] || 'mongo2'
when /^moped/
  require 'moped'
when /^mongo/
  require 'mongo'
else
  fail "Invalid MONGO_VERSION: #{ENV['MONGO_VERSION']}."
end

require 'spidey-mongo'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.raise_errors_for_deprecations!
end
