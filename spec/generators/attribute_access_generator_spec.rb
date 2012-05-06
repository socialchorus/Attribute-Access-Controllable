require "spec_helper"
require 'rails/generators/active_record'
require 'generators/attribute_access/attribute_access_generator'

describe AttributeAccessGenerator do
  before { 
    prepare_destination
    run_generator %w(Person)
  }
  describe "the migration" do
    subject { migration_file('db/migrate/add_read_only_attributes_to_people.rb') }
    it { should exist }
    it { should be_a_migration }
    it { should contain 'class AddReadOnlyAttributesToPeople < ActiveRecord::Migration' }
    it { should contain 'add_column :people, :read_only_attributes, :text'}
  end
  
  describe "the class" do
    subject { file('app/models/person.rb') }
    it { should exist }
    it { should contain 'include AttributeAccessControllable' }
  end
end
