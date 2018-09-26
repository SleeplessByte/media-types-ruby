# frozen_string_literal: true

module Assertions
  module MediaTypes
    def assert_media_type_format(media_type, output, **opts)
      if media_type.collection?
        output[:_embedded].each do |embedded|
          assert_media_type_format(media_type.view(nil), embedded, **opts)
        end
        return
      end

      if media_type.index?
        return output[:_index] # TODO: sub_schema the "self" link
      end

      assert media_type.validate!(output, **opts)
    end
  end
end
