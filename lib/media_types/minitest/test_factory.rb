require 'minitest/autorun'

class Minitest::Test < Minitest::Runnable
  include MediaTypes::Assertions
  def self.assert_mediatype_specification(type)
    scheme = type.media_type_validations.scheme

    scheme.fixtures.each_with_index do |fixture_data, counter|
      json = JSON.parse(fixture_data.fixture, { symbolize_names: true })
      test_name = "test_fixture#{counter}_#{fixture_data.expect_to_pass ? 'assert_pass' : 'assert_fail'}_for_#{type.to_constructable})"

      define_method test_name do
        processed = fixture_data.expect_to_pass ? scheme.process_assert_pass(json, fixture_data.caller) : scheme.process_assert_fail(json, fixture_data.caller)
        traceless_assert processed.nil?,  fixture_data.expect_to_pass ? processed : MediaTypes::MediaTypeValidationError.new(json, fixture_data.caller).message
      end
    end
  end
end
