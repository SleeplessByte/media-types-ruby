# frozen_string_literal: true

module MediaTypes
  class Defaults
    def initialize(media_type, &block)
      self.media_type = media_type

      instance_exec(&block) if block_given?
    end

    def method_missing(method_name, *arguments, &block)
      if media_type.respond_to?(method_name)
        return self.media_type = media_type.send(method_name, *arguments, &block)
      end

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      media_type.respond_to?(method_name) || super
    end

    def to_constructable
      media_type
    end

    private

    attr_accessor :media_type
  end
end
