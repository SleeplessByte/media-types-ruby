# frozen_string_literal: true

module MediaTypes
  class Scheme
    class Attribute

      ##
      # An attribute that expects a value of type +type+
      #
      # @see AllowNil
      # @see AnyOf
      #
      # @param [Class] type the class +it+ must be
      # @param [TrueClass, FalseClass] allow_nil if true, nil? is allowed
      #
      def initialize(type, allow_nil: false)
        self.type = type
        self.allow_nil = allow_nil

        freeze
      end

      def validate!(output, options, **_opts)
        if output.nil?
          return true if allow_nil
        end

        return true if type === output # rubocop:disable Style/CaseEquality
        raise ValidationError,
              format(
                'Expected %<type>s, got %<actual>s at [%<backtrace>s]',
                type: type,
                actual: output.inspect,
                backtrace: options.backtrace.join('->')
              )
      end

      private

      attr_accessor :allow_nil, :type

    end
  end
end
