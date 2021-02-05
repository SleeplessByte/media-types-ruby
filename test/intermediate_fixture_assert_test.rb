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

  class TestThatWholeContextOfBlockIsUsedCollection
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'TestThatWholeContextOfBlockIsUsedCollection'

    validations do
      assert_pass '{"foo":[{"bar":9}]}' # Test that we can define a fixture in a block before the rules
      collection :foo do
        assert_pass '[{"bar":9}]' # Test that we can define a fixture in a block before the rules
        attribute :bar, Numeric
        assert_pass '[{"bar":11}]' # And afterwards
      end
      assert_pass '{"foo":[{"bar":11}]}' # And afterwards
    end
  end

  class TestThatOptionalIsUsedCorrectlyCollection
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'TestThatOptionalIsUsedCorrectlyCollection'

    validations do
      collection :foo, optional: true do
        attribute :bar, Numeric
        assert_pass '[{"bar":9}]'
      end
      assert_pass '{}'
    end
  end

  ### Link ###

  class BasicFixtureTypeLink
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'BasicFixtureTypeLink'

    validations do
      link :foo do
        assert_pass '{ "href": "https://example.org/s" }'
      end
      assert_pass '{ "_links": { "foo": { "href": "https://example.org/s"} } }'
    end
  end

  class TestThatWholeContextOfBlockIsUsedLink
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'TestThatWholeContextOfBlockIsUsedLink'

    validations do
      assert_pass '{ "_links": { "foo": { "href": "https://example.org/s", "bar": 9} } }' # Test that we can define a fixture in a block before the rules
      link :foo do
        assert_pass '{ "href": "https://example.org/s", "bar": 9 }' # Test that we can define a fixture in a block before the rules
        attribute :bar, Numeric
        assert_pass '{ "href": "https://example.org/s", "bar": 9 }' # And afterwards
      end
      assert_pass '{ "_links": { "foo": { "href": "https://example.org/s", "bar": 9} } }' # And afterwards
    end
  end

  class TestThatOptionalIsUsedCorrectlyLink
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'TestThatOptionalIsUsedCorrectlyLink'

    validations do
      link :foo, optional: true do
        assert_pass '{ "href": "https://example.org/s" }'
      end
      assert_pass '{ "_links": {} }'
    end
  end

  ### Calling assert_sane on all the test cases ###

  [BasicFixtureTypeNestedAttribute,
    TestThatWholeContextOfBlockIsUsedAttribute,
    TestThatOptionalIsUsedCorrectlyAttribute,
    BasicFixtureTypeCollection,
    TestThatWholeContextOfBlockIsUsedCollection,
    TestThatOptionalIsUsedCorrectlyCollection,
    BasicFixtureTypeLink,
    TestThatWholeContextOfBlockIsUsedLink,
    TestThatOptionalIsUsedCorrectlyLink
    ].each do |type|
    assert_mediatype_specification type
  end

  class NestedAssertsTypeAttribute
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
      NestedAssertsTypeAttribute.assert_sane!
    end
  end

  class NestedAssertsTypeCollection
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'nested_assert_pass'

    validations do
      collection :foo do
        assert_pass '[{"bar": "9"}]'
        assert_fail '[{"bar": "9"}]'
        attribute :bar, Numeric
      end
    end
  end

  def test_nested_asserts_are_evaluated
    assert_raises MediaTypes::AssertionError do
      NestedAssertsTypeCollection.assert_sane!
    end
  end

  class NestedAssertsTypeLink
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
        'domain.test'
    end

    use_name 'nested_assert_pass'

    validations do
      link :foo do
        attribute :bar, Numeric
        assert_pass '{ "href": "https://example.org/s", "bar":9 }'
        assert_fail '{ "href": "https://example.org/s", "bar":9 }'
      end
    end
  end

  def test_nested_asserts_are_evaluated
    assert_raises MediaTypes::AssertionError do
      NestedAssertsTypeLink.assert_sane!
    end
  end

end
