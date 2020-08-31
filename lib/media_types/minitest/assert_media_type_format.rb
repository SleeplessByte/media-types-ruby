# frozen_string_literal: true

module MediaTypes
  module Assertions
    def assert_media_type_format(media_type, output, **opts)
      return pass unless media_type.validatable?

      assert media_type.validate!(output, **opts)
    end

    def traceless_assert(test, msg = nil)
      msg ||= 'Failed assertion, no message given.'
      self.assertions += 1
      unless test
        msg = msg.call if msg.is_a?(Proc)
        raise MiniTest::Assertion, msg, ''
      end
      true
    end
  end
end