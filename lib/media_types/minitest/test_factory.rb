# frozen_string_literal: true

module Minitest
  class Test < Minitest::Runnable
    def self.create_specification_tests_for(mediatype)
      define_method "test_mediatype_specification_of_#{mediatype.name}" do
        assert_mediatype_specification mediatype
      end
    end
  end
end
