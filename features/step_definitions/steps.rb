World(Aruba::Api)

Given /^a new rails application$/ do
  run_simple "rails new test_app --quiet --force --skip-bundle --skip-test-unit --skip-javascript --skip-sprockets"
  cd '/test_app'
  use_clean_gemset 'test_app'
  write_file '.rvmrc', "rvm use default@test_app\n"
  append_to_file 'Gemfile', <<EOT
gem 'attribute_access_controllable', :path => '../../..'
gem 'rspec-rails'
EOT
  run_simple 'bundle install --quiet'
  run_simple 'script/rails generate rspec:install'
end

Given /^I generate a new migration for the class "(.*?)"$/ do |klass|
  cmd = "rails generate model #{klass} attr1:string --test-framework"
  run_simple cmd
  output = stdout_from cmd
  assert_partial_output "invoke  active_record", output
  
  cmd = "rake db:migrate"
  run_simple cmd
  output = stdout_from cmd
  assert_matching_output %q{==  Create.+: migrating}, output
  assert_matching_output %q{==  Create.+: migrated}, output
end

Given /^I generate an attribute access migration for the class "(.*?)"$/ do |klass|
  cmd = "rails generate attribute_access #{klass}"
  run_simple cmd
  output = stdout_from cmd
  assert_matching_output "create\\s+db/migrate/\\d+_add_read_only_attributes_to_.+\.rb", output
  assert_matching_output "insert\\s+app/models/.+\.rb", output

  cmd = "rake db:migrate"
  run_simple cmd
end

Given /^I have a test that exercises read\-only$/ do
  overwrite_file 'spec/models/person_spec.rb', <<EOT
require 'spec_helper'
require 'attribute_access_controllable/spec_support'

describe Person do
  it_should_behave_like "it has AttributeAccessControllable", :attr1
end
EOT
end
