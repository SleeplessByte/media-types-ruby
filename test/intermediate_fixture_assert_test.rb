# frozen_string_literal: true

require_relative './test_helper'

class IntermediateFixtureAssertTest < Minitest::Test

  class BasicFixtureType
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    # Some first time tests to find out how current code behaves and how we want it to behave

    # default attribute (=hash object)
    validations do
      assert_pass '{}' # I assume that we test all of the current rules, which is none so far
      attribute :foo do
        assert_pass '{}' # Are we testing the contents of :foo? which defaults to hash
        assert_pass '{"foo" : {}}' # Or are we testing everything up to this point?
      end
      assert_pass '{"foo" : {}}' # This should definiatly be the ruleset by now, right?
    end
  end

  class BasicFixtureTypeNonDefaultAttribute
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
      'domain.test'
    end

    use_name 'testNonDefaultAttribute'

    # Some first time tests to find out how current code behaves and how we want it to behave
    # This time a little fancier with an specified attribute type. Most things commented out because WIP

    # non-default attribute
    validations do
      # assert_pass '{}' # I assume that we test all of the current rules, which is none so far
      attribute :foo, Numeric do # Is this 'do' block even possible here?
        # assert_pass '{9}' # Are we testing the contents of :foo? which defaults to hash
        # assert_pass '{"foo" : 9}' # Or are we testing everything up to this point?
      end
      # assert_pass '{"foo" : 9}' # This should definiatly be the ruleset by now, right?
    end
  end

  class BasicFixtureTypeDouble
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
      'domain.test'
    end

    use_name 'test_double'

    # See how nested things are handled. Still WIP

    validations do
      attribute :foo do
        assert_pass '{"foo": 9}'
      end
      attribute :bar do
        assert_pass '{"bar": 9}'
      end
    end
  end

  [BasicFixtureType,
   BasicFixtureTypeNonDefaultAttribute,
   BasicFixtureTypeDouble].each do |type|
    assert_mediatype_specification type
  end

end
