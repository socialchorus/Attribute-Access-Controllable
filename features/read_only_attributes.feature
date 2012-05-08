@announce-cmd
Feature: Read only attributes

Scenario: In a simple rails application
  Given a new rails application
  And I generate a new migration for the class "Person"
  And I generate an attribute access migration for the class "Person"
  And I have a test that exercises read-only
  When I run `rake spec`
  Then the output should contain "8 examples, 0 failures"


