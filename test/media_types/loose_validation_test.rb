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
      assert_pass '{"foo":{}}', loose: true
      assert_fail '{"foo":{}}', loose: false
    end
  end

  [TestLooseAttributes].each do |type|
    create_specification_tests_for type
  end
end
