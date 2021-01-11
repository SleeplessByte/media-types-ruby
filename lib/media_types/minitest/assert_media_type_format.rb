# frozen_string_literal: true

module MediaTypes
  module Assertions
    def assert_media_type_format(media_type, output, **opts)
      return pass unless media_type.validatable?

      assert media_type.validate!(output, **opts)
    end
  end
end
