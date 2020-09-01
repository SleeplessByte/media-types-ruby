require 'minitest/autorun'

class Minitest::Test < Minitest::Runnable
  include MediaTypes::Assertions
  def self.build_fixture_tests(type)
    scheme = type.media_type_validations.scheme
    counter = 1
    scheme.fixtures.each do |object|
      json = JSON.parse(object.fixture, { symbolize_names: true })
      caller = object.caller
      test_type = object.expect_to_pass ? 'assert_pass' : 'assert_fail'
      string = "test_fixture#{counter}_#{test_type}_for_#{type.to_constructable})"
      output = object.expect_to_pass ? scheme.process_assert_pass(json, caller) : scheme.process_assert_fail(json, caller)
      message = object.expect_to_pass ? output : MediaTypes::MediaTypeValidationError.new(json, caller).message
      define_method string do
        traceless_assert output.nil?, message
      end
      counter += 1
    end
  end
end
