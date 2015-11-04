source 'http://rubygems.org'

case version = ENV['MONGO_VERSION'] || 'mongo2'
when /^moped/
  gem 'moped', '~> 2.0'
when /^mongo2/
  gem 'mongo', '~> 2.0'
when /^mongo/
  gem 'mongo', '~> 1.12'
  gem 'bson_ext'
else
  fail "Invalid MONGO_VERSION: #{ENV['MONGO_VERSION']}."
end

# Specify your gem's dependencies in spidey-mongo.gemspec

gemspec
