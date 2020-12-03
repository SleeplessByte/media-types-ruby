require 'minitest/autorun'

class Minitest::Test < Minitest::Runnable
  include MediaTypes::Assertions
  def self.assert_mediatype_specification(mediatype)
    fixtures = mediatype.media_type_validations.scheme.fixtures

    fixtures.each_with_index do |fixture_data, counter|
      config = if fixture_data.expect_to_pass
                 passing_config(mediatype, fixture_data, counter)
               else
                 failing_config(mediatype, fixture_data, counter)
               end
      generate_test(config)
    end
  end

  def passing_config(mediatype, fixture_data, counter)
    json = JSON.parse(fixture_data.fixture, { symbolize_names: true })
    {
      test_name: "test_fixture#{counter}_assert_pass_for_#{mediatype.to_constructable})",
      processed: mediatype.media_type_validations.scheme.process_assert_pass(json, fixture_data.caller),
      message: processed
    }
  end

  def failing_config(mediatype, fixture_data, counter)
    json = JSON.parse(fixture_data.fixture, { symbolize_names: true })
    {
      test_name: "test_fixture#{counter}_assert_fail_for_#{mediatype.to_constructable})",
      processed: mediatype.media_type_validations.scheme.process_assert_fail(json, fixture_data.caller),
      message: MediaTypes::MediaTypeValidationError.new(json, fixture_data.caller).message
    }
  end

  def generate_test(config)
    define_method config[:test_name] do
      assert true
      raise Minitest::Assertion, config[:message], '' unless config[:processed].nil?
    end
  end
end
