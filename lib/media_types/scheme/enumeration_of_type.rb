# frozen_string_literal: true

module MediaTypes
  class Scheme
    class EnumerationOfType

      ##
      # An attribute that expects a value of type +enumeration_type+ and each item of type +item_type+
      #
      # @param [Class] item_type the type of each item
      # @param [Class] enumeration_type the type of the enumeration as a whole
      # @param [TrueClass, FalseClass] allow_empty if true, an empty instance of +enumeration_type+ is valid
      #
      def initialize(item_type, enumeration_type: Array, allow_empty: false)
        self.item_type = item_type
        self.enumeration_type = enumeration_type
        self.allow_empty = allow_empty

        freeze
      end

      def validate!(output, options, **_opts)
        validate_enumeration!(output, options) &&
          validate_not_empty!(output, options) &&
          validate_items!(output, options)
      end

      def inspect
        "[Scheme::EnumerationOfType #{item_type} collection=#{enumeration_type} empty=#{allow_empty}]"
      end

      private

      attr_accessor :allow_empty, :enumeration_type, :item_type

      def validate_enumeration!(output, options)
        return true if enumeration_type === output # rubocop:disable Style/CaseEquality
        raise ValidationError,
              format(
                'Expected collection as %<type>s, got %<actual>s at [%<backtrace>s]',
                type: enumeration_type,
                actual: output.inspect,
                backtrace: options.backtrace.join('->')
              )
      end

      def validate_not_empty!(output, options)
        return true if allow_empty
        return true if output.respond_to?(:length) && output.length.positive?
        return true if output.respond_to?(:empty?) && !output.empty?

        raise EmptyOutputError,
              format(
                'Expected collection to be not empty, got empty at [%<backtrace>s]',
                backtrace: options.backtrace.join('->')
              )
      end

      def validate_items!(output, options)
        output.all? do |item|
          next true if item_type === item # rubocop:disable Style/CaseEquality
          raise ValidationError,
                format(
                  'Expected collection item as %<type>s, got %<actual>s at [%<backtrace>s]',
                  type: item_type,
                  actual: item.inspect,
                  backtrace: options.backtrace.join('->')
                )
        end
      end

    end
  end
end
