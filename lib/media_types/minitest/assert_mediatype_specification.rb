# frozen_string_literal: true

module MediaTypes
  module Assertions
    def assert_mediatype_specification(mediatype)
      mediatype.assert_sane!
      assert mediatype.media_type_validations.scheme.asserted_sane?
    rescue MediaTypes::AssertionError => e
      flunk e.message
    end
  end
end
