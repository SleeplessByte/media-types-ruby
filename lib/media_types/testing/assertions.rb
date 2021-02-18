# frozen_string_literal: true

module MediaTypes
  module Testing
    module Assertions
      def assert_media_type_format(media_type, output, **opts)
        return pass unless media_type.validatable?

        assert media_type.validate!(output, **opts)
      end

      def assert_mediatype(mediatype)
        mediatype.assert_sane!
        assert mediatype.media_type_validations.scheme.asserted_sane?
      rescue MediaTypes::AssertionError => e
        flunk e.message
      end
    end
  end
end
