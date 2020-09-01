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
    # traceless_assert enables you to write test factories and so one without providing a backtrace to the code where the method was defined, apart from this, it is identical to a normal assert.
    # this is so that you can create methods such as the ones in ./test_factory.rb which only provide information captured in the error,
    # and avoid providing an unhelpful backtrace to the file where the template test was written.
  end
end
