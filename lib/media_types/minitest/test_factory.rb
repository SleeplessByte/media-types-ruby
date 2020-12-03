require 'minitest/autorun'

class Minitest::Test < Minitest::Runnable
  include MediaTypes::Assertions
  def self.assert_mediatype_specification(type)
    scheme = type.media_type_validations.scheme

    scheme.fixtures.each_with_index do |fixture_data, counter|
      json = JSON.parse(fixture_data.fixture, { symbolize_names: true })
      test_name = "test_fixture#{counter}_#{fixture_data.expect_to_pass ? 'assert_pass' : 'assert_fail'}_for_#{type.to_constructable})"

      generate_test(test_name, fixture_data, scheme, json)
    end
  end

  def generate_test(test_name, fixture_data, scheme, json)
    define_method test_name do
      if fixture_data.expect_to_pass
        processed = scheme.process_assert_pass(json, fixture_data.caller)
        msg = processed
      else
        processed = scheme.process_assert_fail(json, fixture_data.caller)
        msg = MediaTypes::MediaTypeValidationError.new(json, fixture_data.caller).message
      end

      assert true
      raise Minitest::Assertion, msg, '' unless processed.nil?
    end
  end
end
