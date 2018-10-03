# frozen_string_literal: true

require 'media_types/scheme/errors'
require 'media_types/scheme/allow_nil'

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
        self.type = allow_nil ? Scheme.AllowNil(type) : type

        freeze
      end

      def validate!(output, options, **_opts)
        return true if type === output # rubocop:disable Style/CaseEquality
        raise ValidationError,
              format(
                'Expected %<type>s, got %<actual>s at [%<backtrace>s]',
                type: type,
                actual: output.inspect,
                backtrace: options.backtrace.join('->')
              )
      end

      def inspect
        "[Scheme::Attribute of #{type.inspect}]"
      end

      private

      attr_accessor :allow_nil, :type

    end
  end
end
