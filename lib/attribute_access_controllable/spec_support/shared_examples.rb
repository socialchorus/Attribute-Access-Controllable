shared_examples_for "it has AttributeAccessControllable" do |test_column|
  it "#attr_read_only(:attribute, ...) marks an attribute as read-only" do
    expect {
      subject.attr_read_only(test_column)
    }.to change(subject, :read_only_attributes).from(nil).to(Set.new([test_column.to_s]))
  end

  it "#read_only_attribute?(:attribute) returns true when marked read-only" do
    subject.read_only_attributes = Set.new([test_column.to_s])
    subject.should be_read_only_attribute(test_column)
  end

  it "#read_only_attribute?(:attribute) returns false when not marked read-only (or not marked at all)" do
    subject.should_not be_read_only_attribute(test_column)
  end

  it "#save! raises error when :attribute is read-only" do
    subject.attr_read_only(test_column)
    subject.send(test_column.to_s + '=', 0)
    expect { subject.save!(context: :update) }.to raise_error ActiveRecord::RecordInvalid
    subject.errors[test_column].should =~ ["is invalid", "is read_only"]
  end

  it "#save!(:context => :skip_read_only) is okay" do
    subject.attr_read_only(test_column)
    subject.send(test_column.to_s + '=', 0)
    expect { subject.save!(:skip_read_only => true) }.to_not raise_error
  end

  it "#save is invalid when :attribute is read-only" do
    subject.attr_read_only(test_column)
    subject.send(test_column.to_s + '=', 0)
    subject.save(context: :update).should be_false
    subject.errors[test_column].should =~ ["is invalid", "is read_only"]
  end

  it "#save(:context => :skip_read_only) is okay" do
    subject.attr_read_only(test_column)
    subject.send(test_column.to_s + '=', 0)
    subject.save!(:skip_read_only => true).should_not be_false
  end

  #it "#attr_writable(:attribute)"
end
