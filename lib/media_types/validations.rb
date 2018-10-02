# frozen_string_literal: true

require 'media_types/scheme'

module MediaTypes
  ##
  # Takes care of registering validations for a media type. It allows for nested schemes and registers each one so it
  # can be looked up at a later time.
  #
  # @see MediaType::Dsl
  # @see Scheme
  #
  class Validations

    ##
    # Creates a new stack of validations
    #
    # @param [Constructable] media_type a Constructable media type
    # @param [Hash] registry the registry reference, or nil if top level
    # @param [Scheme] scheme the current scheme or nil if top level
    #
    # @see MediaTypes::Dsl
    # @see Constructable
    # @see Scheme
    #
    def initialize(media_type, registry = {}, scheme = Scheme.new, &block)
      self.media_type = media_type
      self.registry = registry.merge!(media_type.to_s => scheme)
      self.scheme = scheme

      instance_exec(&block) if block_given?
    end

    ##
    # Looks up the validations for Constructable
    #
    # @param [String, Constructable] media_type
    # @param [lambda] default the lambda if nothing can be found
    # @return [Scheme] the scheme for the given +media_type+
    #
    def find(media_type, default = -> { Scheme.new(allow_empty: true) { not_strict } })
      registry.fetch(String(media_type)) do
        default.call
      end
    end

    def method_missing(method_name, *arguments, &block)
      if scheme.respond_to?(method_name)
        return scheme.send(method_name, *arguments, &block)
      end

      super
    end

    def respond_to_missing?(method_name, include_private = false)
      scheme.respond_to?(method_name) || super
    end

    private

    attr_accessor :media_type, :registry, :scheme

    ##
    # Switches the inner block to a specific version
    #
    # @param [Numeric] version the version to switch to
    #
    def version(version, &block)
      Validations.new(media_type.version(version), registry, &block)
    end

    ##
    # Switches the inner block to a specific view
    #
    # @param [String, Symbol] view the view to switch to
    #
    def view(view, &block)
      Validations.new(media_type.view(view), registry, &block)
    end
  end
end
