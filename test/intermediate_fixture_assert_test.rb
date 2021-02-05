# frozen_string_literal: true

require_relative './test_helper'

class IntermediateFixtureAssertTest < Minitest::Test
  ### Attribute ###

  class BasicFixtureTypeNestedAttribute
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'BasicFixtureType'

    # default attribute (=hash object)
    validations do
      attribute :foo do
        assert_pass '{}' # Test everything in this block, which is just an empty hash
      end
    end
  end
  
  class TestThatWholeContextOfBlockIsUsedAttribute
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'TestThatWholeContextOfBlockIsUsed'

    # default attribute (=hash object)
    validations do
      assert_pass '{"foo":{"bar":9}}' # Test that we can define a fixture in a block before the rules
      attribute :foo do
        assert_pass '{"bar":9}' # Test that we can define a fixture in a block before the rules
        attribute :bar, Numeric
        assert_pass '{"bar":11}' # And afterwards
      end
      assert_pass '{"foo":{"bar":11}}' # And afterwards
    end
  end

  class TestThatOptionalIsUsedCorrectlyAttribute
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'TestThatOptionalIsUsedCorrectly'

    # default attribute (=hash object)
    validations do
      attribute :foo, optional: true do
        attribute :bar, Numeric
        assert_pass '{"bar":9}'
      end
      assert_pass '{}'
    end
  end

  ### Collection ###

  class BasicFixtureTypeCollection
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'BasicFixtureType'

    validations do
      collection :foo do
        assert_pass '[]'
        assert_fail '{}'
      end
    end
  end

  [BasicFixtureTypeNestedAttribute,
    TestThatWholeContextOfBlockIsUsedAttribute,
    TestThatOptionalIsUsedCorrectlyAttribute,
    BasicFixtureTypeCollection
    ].each do |type|
    assert_mediatype_specification type
  end

  class NestedAssertsType
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'nested_assert_pass'

    validations do
      attribute :foo do
        assert_pass '{"bar": "9"}'
        assert_fail '{"bar": "9"}'
        attribute :bar, Numeric
      end
    end
  end

  def test_nested_asserts_are_evaluated
    assert_raises MediaTypes::AssertionError do
      NestedAssertsType.assert_sane!
    end
  end

end
