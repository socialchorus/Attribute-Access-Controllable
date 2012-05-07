# Read-only access at attribute granularity

One of the many pleasures of working at Pivotal Labs is that we are encouraged to release some of our work as open source. Often during the course of our engagements, we write code that might have wide-spread use. Due to the nature of our contracts, we can not unilaterally release such code. Those rights belong to the client. And rightly so. So, it is an even greater pleasure when one of our clients believes in "giving back" to the community, as well. 

One such example is this modest gem, `attribute-access-controllable` which allows you to control read-only access at the _attribute_ level, on a per-instance basis. For example, let's say that you have a model `Person` with an attribute `birthday`, which, for security purposes, cannot be changed once this attribute is set (except, perhaps, by an administrator with extraordinary privileges). Any future attempts to change this attribute will result in a validation error.

e.g.

    > alice = Person.new(:birthday => '12/12/12')
    => #<Person id: nil, attr1: nil, created_at: nil, updated_at: nil, read_only_attributes: nil, birthday: "0012-12-12"> 
    > alice.attr_read_only(:birthday)
    => #<Set: {"birthday"}> 
    > alice.save!
    => true
    > alice.birthday = "2012-12-12"
    => "2012-12-12" 
    > alice.save!
    ActiveRecord::RecordInvalid: Validation failed: Birthday is invalid, Birthday is read_only
    > alice.save!(:skip_read_only => true)
    => true
    
Setting this up is trivial, thanks to a Rails generator which does most of the heavy lifting for you.

    rails generate attribute_access Person
    
After that, you need only know about one new method added to your class:

    #attr_read_only(*attributes) # Marks attributes as read-only
    
There are a few others, but this one, plus the new functionality added to `#save` and `#save!` will get you quite far.

And if that's all that you were looking for when you stumbled across this article, then there's no need to read any further. Go install the gem and have fun (and may your tests be green when you expect them to be).

## From customer requirements to releasable gem

On the other hand, if you are interested in how we got from the original customer story to a releasable open sourced gem, read on. The source code for the module is a [mere 34 lines long](https://github.com/halogenguides/Attribute-Access-Controllable/blob/master/lib/attribute_access_controllable.rb). It implements 2 new methods, a validator and (gently) overrides `#save` and `#save!`. Being good Test Driven Developers, we wrote our specs first, and since we wanted this behavior to be included in several models, we wrote our specs as a [_shared behavior_](https://github.com/halogenguides/Attribute-Access-Controllable/blob/master/lib/attribute_access_controllable/spec_support/shared_examples.rb) as well. The spec clocks in at 44 lines, slightly longer than our implementation. All in all, tiny. The whole commit was less than 100 lines of code.

    AttributeAccessControllable
      it should behave like it has AttributeAccessControllable
        #attr_read_only(:attribute, ...) marks an attribute as read-only
        #read_only_attribute?(:attribute) returns true when marked read-only
        #read_only_attribute?(:attribute) returns false when not marked read-only (or not marked at all)
        #save! raises error when :attribute is read-only
        #save!(:context => :skip_read_only) is okay
        #save is invalid when :attribute is read-only
        #save(:context => :skip_read_only) is okay 

In order to get to something "releasable" we needed a few more things, which we put on our To-Do list:

#### To do
  1. MIT License
  2. A gem specification
  3. Basic documentation in a README file

The list got longer as we fleshed out both the documentation and the integration tests, as you'll see in a moment, but first, let's talk about

### Getting the legal issues resolved, easily and quickly

Pivotal's open sourcing policy is straightforward and simple to execute; We don't touch it. We write code for our clients, it's their code to do with as they please. My particular client liked the work we did for them and thought it would make a great open source gem. The Director of Engineering signed off on the idea and I paired with him to create the github repository during a lunch break. The first commit was tiny, just a basic directory structure and the existing code. I don't think the tests passed because they lacked a proper RSpec infrastructure.

### Creating the gem

    bundler gem DIRECTORY

is your best friend. It set up the layout for us, including an MIT License and a gem specificiation. It had a boilerplate README, too.

### Writing the documentation for the code you wished you had

Next, we wrote a draft of the README file which documented what we knew (you needed a migration to create a column called `:read_only_attributes` and you needed to include the module into the class). Then we started thinking about the pain points of using our code as is. Wouldn't it be nice if we could create the migration automatically? Rails generators do that sort of thing, how hard could it be? (Famous last words...) It became clear that we needed to test drive out some new features of the _gem_ that supported the actual _module_.

#### To do
  1. <strike>MIT License</strike>
  2. <strike>A gem specification</strike>
  3. <strike>Basic documentation in a README file</strike>
  4. Integration test

### I am not a big cucumber fan, but...

Really, I'm not. I used to write them all the time, but nowadays, I use a combination of RSpec and Capybara to get most of my day-to-day integration testing done. There is, however, one sweet spot for Cucumber that I'm finding more and more useful; A very high-level document that describes essential features in a way that a reader will say, "Ahhh, so _that_ is how it is supposed to work!" Here's a copy of the spec I wrote:

    Feature: Read only attributes

    Scenario: In a simple rails application
      Given a new rails application
      And I generate a new migration for the class "Person"
      And I generate an attribute access migration for the class "Person"
      And I have a test that exercises read-only
      When I run `rake spec`
      Then the output should contain "7 examples, 0 failures"

You probably won't find any web-steps out there to handle these lines. I use [Aruba](https://github.com/cucumber/aruba) to handle the dirty work of executing shell commands in a safe sandbox-y way. The [step definition file](https://github.com/halogenguides/Attribute-Access-Controllable/blob/master/features/step_definitions/steps.rb) hides all the ugliness away. Even so, most readers could figure out what to do, by hand, for each step.

#### To do
  1. <strike>MIT License</strike>
  2. <strike>A gem specification</strike>
  3. <strike>Basic documentation in a README file</strike>
  4. <strike>Integration test</strike>
  5. Generator

### Big generators

This gem was my first attempt at writing a generator, so it was awkward. I still don't understand [Thor](https://github.com/wycats/thor) properly. Fortunately, I happened upon [Ammeter](https://github.com/alexrothenberg/ammeter), which helped me write out test specs for the generator. If you've got good specs, then you can sometimes stumble along until you learn enough to get it right. Alex Rothenberg's original [blog post](http://www.alexrothenberg.com/2011/10/10/ammeter-the-way-to-write-specs-for-your-rails-generators.html) about the gem was quite informative, as were the test cases from the [Devise](https://github.com/plataformatec/devise/tree/master/test/generators) gem.

I have to admit; constructing the generator was more complex than the original module! There are more "moving parts;" templates, usage files, specs, in addition to the generator itself. So there is a certain amount of overhead that might overwhelm the original content. On the other hand, I learned quite a bit, and the gem is far more useful.

    require "spec_helper"
    require 'generators/attribute_access/attribute_access_generator'

    describe AttributeAccessGenerator do
      before do
        prepare_destination
        Rails::Generators.options[:rails][:orm] = :active_record
      end

      describe "the migration" do
        before { run_generator %w(Person) }
        subject { migration_file('db/migrate/create_people.rb') }
        it { should exist }
        it { should be_a_migration }
        it { should contain 'class CreatePeople < ActiveRecord::Migration' }
        it { should contain 'create_table :people do |t|'}
        it { should contain 't.text :read_only_attributes'}
      end
      
      describe "the class" do
        before { run_generator %w(Person) }
        subject { file('app/models/person.rb') }
        it { should exist }
        it { should contain 'include AttributeAccessControllable' }
      end

Some interesting things to note; you must `require` the generator, since it is not pulled in by default. The subject of each suite is a _file_, not the class `AttributeAccessGenerator`. The `migration_file` helper prepends the TIMESTAMP onto the migration file for you. If you need to set up more things for your test, `destination_root` is a helper with a path to the temporary directory. It remains after the tests have run, which makes it useful when debugging.

Here's something that I did not know, but it might help new generator writers; the order in which you define your methods in the generator class is _significant_. I don't know how this is done, but each "method" in the generator class is executed in turn. This is important for my generator; the model class definition _must_ exist before I inject the new content that mixes in the module, so I had to write the `generate_model` method before the `inject_attribute_access_content` method. I was scratching my head over that one for quite awhile.

    require "rails/generators/active_record"

    class AttributeAccessGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
  
      def create_migration_file
        if (behavior == :invoke && model_exists?)
          migration_template "migration.rb", "db/migrate/add_read_only_attributes_to_#{table_name}"
        else
          migration_template "migration_create.rb", "db/migrate/create_#{table_name}"
        end
      end
  
      def generate_model
        invoke "active_record:model", [name], :migration => false unless model_exists? && behavior == :invoke
      end
  
      def inject_attribute_access_content
        class_path = class_name.to_s.split('::')
    
        indent_depth = class_path.size
        content = "  " * indent_depth + 'include AttributeAccessControllable' + "\n"
    
        inject_into_class(model_path, class_path.last, content)
      end

#### To do
  1. <strike>MIT License</strike>
  2. <strike>A gem specification</strike>
  3. <strike>Basic documentation in a README file</strike>
  4. <strike>Integration test</strike>
  5. <strike>Generator</strike>
  6. Shareable tests
  
## Yo, I hear you like tests in your tests

Lastly, we want to share the testing love. The gem consumer should not have to _write_ tests to drive out the same feature that we have already tested. That would not be very DRY. So, in order to make our shared behavior, er, um, _shareable_, we moved it into `lib` with a few wrappers, namely, the `spec_support.rb` file, which you can include in your own spec files to test drive adding the module to your own classes.

Which is where `And I have a test that exercises read-only` comes in. You can see this in the `steps.rb` file:

    require 'spec_helper'
    require 'attribute_access_controllable/spec_support'

    describe Person do
      it_should_behave_like "it has AttributeAccessControllable", :attr1
    end

#### To do
  1. <strike>MIT License</strike>
  2. <strike>A gem specification</strike>
  3. <strike>Basic documentation in a README file</strike>
  4. <strike>Integration test</strike>
  5. <strike>Generator</strike>
  6. <strike>Shareable tests</strike>
  
## Don't be afraid to release v1.0.0

I am a strong believer in [semantic versioning](http://semver.org/). I simply can not understand why some core ruby tools are still living in version zero land, even after years and years of development and use. So, after a couple of internal commits, we released v1.0.0 of the gem, and less than a day later released v1.1.0 and then v1.1.1! (You probably shouldn't use anything less than v1.1.1)

## An interesting mix

In summary, we used a lot of tools and techniques to go from a simple commit to a shareable gem:

  * Rails generators
  * Cucumber
  * Aruba
  * Ammeter
  * RSpec shared behaviors
  * Integration tests
  * Generator tests
  * Module tests

I encourage everyone to release as much of their work as possible because it raises the state of the art for us all. There are limits, of course, but that still affords lots of wiggle room. Small gems like `attribute_access_controllable` won't change the world, but they ease the pain of staying DRY and we all get to learn a little something.

### Thanks

To Social Chorus for choosing to open source this code. And to Pivotal Labs for encouraging a better way to do software engineering.