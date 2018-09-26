# frozen_string_literal: true

module MediaTypes
  class Scheme
    class NotStrict
      def validate!(*_args, **_opts)
        true
      end
    end
  end
end
