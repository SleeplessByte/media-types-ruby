# frozen_string_literal: true

require_relative './test_helper'

class MediaTypesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MediaTypes::VERSION
  end

  def test_it_requires
    %i[
      Base
      Scheme
    ].each do |klazz|
      assert MediaTypes.const_defined?(klazz),
             format('Expected %<klazz>s to be required', klazz: klazz)
    end
  end
end
