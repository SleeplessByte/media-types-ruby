# frozen_string_literal: true

require_relative '../test_helper'

class LooseValidationTest < Minitest::Test
  ### Attribute ###

  class TestLooseAttributes
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'TestThatWholeContextOfBlockIsUsedAttribute'

    # default attribute (=hash object)
    validations do

      attribute :foo do
        attribute :bar, Numeric, optional: :loose
      end

      attribute :baz, String

      # Loose keys don't need to be present in loose mode
      assert_pass '{"foo":{}, "baz": "hello world"}', loose: true

      # Loose keys must be present in normal mode
      assert_fail '{"foo":{}, "baz": "hello world"}', loose: false

      # All required keys must be present
      assert_fail '{"foo":{}}', loose: true

      # Extra keys not allowed (unless not-strict)
      assert_fail '{"foo":{}, "nope": "unknown"}', loose: true
    end
  end

  [TestLooseAttributes].each do |type|
    create_specification_tests_for type
  end
end
