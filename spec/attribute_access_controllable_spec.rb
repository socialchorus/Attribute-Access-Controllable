require 'spec_helper'
require 'informal'
require 'active_record/errors'
require 'active_record/validations'

require 'attribute_access_controllable'
require 'attribute_access_controllable/spec_support'

class TestFakePersistance
  include Informal::Model
  include ActiveRecord::Validations

  def save(options={})
    perform_validations(options) ? :pretend_to_call_super : false
  end

  def save!(options={})
    perform_validations(options) ? :pretend_to_call_super : raise(ActiveRecord::RecordInvalid.new(self))
  end
end

class TestAttributeAccessControllable < TestFakePersistance
  attr_accessor :read_only_attributes # usually created via a migration
  include ActiveModel::Dirty

  define_attribute_methods [:test_column]

  def test_column
    @test_column
  end

  def test_column=(val)
    test_column_will_change! unless val == @test_column
    @test_column = val
  end

  include AttributeAccessControllable # code under test
end

describe AttributeAccessControllable do
  subject { TestAttributeAccessControllable.new }

  it_should_behave_like "it has AttributeAccessControllable", :test_column
end

