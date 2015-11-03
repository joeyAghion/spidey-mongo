$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'spidey-mongo'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.raise_errors_for_deprecations!
end
