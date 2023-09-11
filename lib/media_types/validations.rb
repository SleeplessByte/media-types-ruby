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

    attr_reader :scheme

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
    def initialize(media_type, registry = {}, scheme = Scheme.new(registry: registry, current_type: media_type), &block)
      self.media_type = media_type
      self.registry = registry.merge!(media_type.as_key => scheme)
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
      registry.fetch(media_type.as_key) do
        default.call
      end
    end


    if Gem::Version.new(RUBY_VERSION) > Gem::Version.new('2.7.0')
      def method_missing(method_name, *arguments, **kwargs, &block)
        if scheme.respond_to?(method_name)
          media_type.__getobj__.media_type_combinations ||= Set.new
          media_type.__getobj__.media_type_combinations.add(media_type.as_key)

          return scheme.send(method_name, *arguments, **kwargs, &block)
        end

        super
      end
    else
      def method_missing(method_name, *arguments, &block)
        if scheme.respond_to?(method_name)
          media_type.__getobj__.media_type_combinations ||= Set.new
          media_type.__getobj__.media_type_combinations.add(media_type.as_key)

          return scheme.send(method_name, *arguments, &block)
        end

        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      scheme.respond_to?(method_name) || super
    end

    private

    attr_accessor :media_type, :registry
    attr_writer :scheme

    ##
    # Switches the inner block to a specific version
    #
    # @param [Numeric] version the version to switch to
    #
    def version(version, &block)
      Validations.new(media_type.version(version), registry, &block)
    end

    ##
    # Runs the block for multiple versions
    #
    # @param [Array] list of versions to run this on
    #
    def versions(versions, &block)
      versions.each do |v|
        Validations.new(media_type.version(v), registry) do
          block.call(v)
        end
      end
    end

    ##
    # Switches the inner block to a specific view
    #
    # @param [String, Symbol] view the view to switch to
    #
    def view(view, &block)
      Validations.new(media_type.view(view), registry, &block)
    end

    def suffix(name)
      scheme.type_attributes[:suffix] = name
    end
  end
end
