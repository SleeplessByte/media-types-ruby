# frozen_string_literal: true

require 'minitest/autorun'

module Minitest
  class Test < Minitest::Runnable
    include MediaTypes::Assertions
    def self.assert_mediatype_specification(mediatype)
      define_method "test_fixtures_for_#{mediatype.to_constructable}" do
        mediatype.assert_sane!
      end
    end
  end
end
