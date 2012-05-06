# AttributeAccessControllable

This gem allows you to control write access at the _attribute_ level, on a per-instance basis. For example, let's say you had a model `Person` that has an attribute, `birthday`, which, for security purposes, once this attribute is set, cannot be changed again (except, perhaps by an administrator with extraordinary privileges). You would want any attempts to change this value to raise a validation error.

e.g.

    alice = Person.create(:birthday => '12/12/12')
    => <Person...>
    alice.birthday= '1/1/01'
    => '1/1/01'
    alice.save!
    => ActiveRecord::RecordInvalid ... "birthday is invalid: birthday is read_only"

## Installation

Add this line to your application's Gemfile:

    gem 'attribute_access_controllable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attribute_access_controllable

## Usage

Generate a migration for your class

    $ rails generate attribute_access:migration Person
    $ rake db:migrate
    
In your model, add the following:

    ```rails
    class Person < ActiveRecord::Base
      include AttributeAccessControllable
      ...
    ```
      
Add hooks to mark attributes as read_only:

    ```rails
    ...
    before_save :mark_birthday_read_only
      
    private
      
      def mark_birthday_read_only
        attr_read_only(:birthday)
      end
    ...
    ```
    
If, in the future, you need by-pass the validations, pass `:skip_read_only => true` to the instance's `save` or `save!` methods.

## RSpec support

Adding this to your model spec will exercise the feature.

    ```rails
    require 'attribute_access_controllable/spec_support'

    describe Person do
      it_should_behave_like "it has AttributeAccessControllable", :test_column
    end
    ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
