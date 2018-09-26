# frozen_string_literal: true

module MediaTypes
  class Scheme
    class Links
      def initialize
        self.links = {}
      end

      def link(key, allow_nil: false, &block)
        scheme = Scheme.new
        scheme.attribute :href, String, allow_nil: allow_nil
        scheme.instance_exec(&block) if block_given?

        links[key] = scheme
      end

      def validate!(output, options, **_opts)
        links.all? do |key, value|
          value.validate!(
            output[key],
            options.trace(key).exhaustive!
          )
        end
      end

      private

      attr_accessor :links
    end
  end
end
