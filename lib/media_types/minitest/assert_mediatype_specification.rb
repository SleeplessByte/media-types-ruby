# frozen_string_literal: true

module MediaTypes
  module Assertions
    def assert_mediatype_specification(mediatype)
      mediatype.assert_sane!
    end
  end
end
