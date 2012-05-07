require "spec_helper"
require 'rails/generators/active_record'
require 'generators/attribute_access/attribute_access_generator'

describe AttributeAccessGenerator do
  before do
    prepare_destination
  end

  context "new class" do
    describe "the migration" do
      before { run_generator %w(Person) }
      subject { migration_file('db/migrate/create_people.rb') }
      it { should exist }
      it { should be_a_migration }
      it { should contain 'class CreatePeople < ActiveRecord::Migration' }
      it { should contain 'create_table :people do |t|'}
      it { should contain 't.text :read_only_attributes'}
    end
  end
  
  context "existing class" do
    describe "the migration" do
      before do
        FileUtils.mkdir_p(File.join(destination_root, "app/models"))
        File.open(File.join(destination_root, "app/models/person.rb"), "w") {|f|
          f.puts "class Person < ActiveRecord::Base\nend\n"
        }
        run_generator %w(Person)
      end
      subject { migration_file('db/migrate/add_read_only_attributes_to_people.rb') }
      it { should exist }
      it { should be_a_migration }
      it { should contain 'class AddReadOnlyAttributesToPeople < ActiveRecord::Migration' }
      it { should contain 'add_column :people, :read_only_attributes, :text'}
    end
  end
  
  describe "the class" do
    before { run_generator %w(Person) }
    subject { file('app/models/person.rb') }
    it { should exist }
    it { should contain 'include AttributeAccessControllable' }
  end
end
