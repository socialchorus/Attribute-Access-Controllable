require 'bundler'
Bundler.setup
require 'ammeter/init'

SPEC_ROOT = File.dirname(__FILE__)

Dir[File.join(SPEC_ROOT, "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
