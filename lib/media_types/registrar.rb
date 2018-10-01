# frozen_string_literal: true

module MediaTypes
  class Registerable
    def initialize(media_type, symbol:, aliases: [])
      self.media_type = media_type
      self.symbol = symbol
      self.aliases = aliases

      freeze
    end

    def to_s
      String(media_type)
    end

    def to_sym
      symbol
    end

    attr_accessor :media_type, :symbol, :aliases

    alias synonyms aliases
    alias mime_type to_s

  end

  ##
  # Holds all the configuration options in order to call {MediaTypes.register} exactly enough times to register the
  # media type in its entirety.
  #
  # @see Registerable
  #
  class Registrar

    ##
    # Creates a new registry with default values
    #
    # @param [Class] klazz the class that has {MediaTypes::Dsl} included
    # @param [Symbol, NilClass] symbol the symbol the base view (nil view) should be registered under
    #
    def initialize(klazz, symbol: nil, &block)
      self.base_media_type = klazz.to_constructable

      self.registered_views = symbol ? { nil => { symbol: String(symbol).to_sym } } : {}
      self.registered_versions = [base_media_type.version]
      self.registered_aliases = []
      self.registered_suffixes = [String(base_media_type.suffix).to_sym]

      instance_exec(&block) if block_given?
    end

    ##
    # Resolves all the permutations and returns a list of {Registerable}
    #
    # @return [Array<Registerable>] the registerables based on all the permutations of +self+
    #
    def to_a
      result = []

      each_resolved do |media_type, symbol|
        result << Registerable.new(media_type, symbol: symbol, aliases: aliases(media_type))
      end

      result
    end

    private

    attr_accessor :registered_views, :registered_versions, :registered_aliases, :registered_suffixes,
                  :symbol_base, :base_media_type

    ##
    # Registers a +view+ with a +symbol+
    #
    # @param [String, Symbol] view the view
    # @param [String, Symbol] symbol the symbol base for this view
    #
    def view(view, symbol)
      registered_views[String(view)] = { symbol: String(symbol).to_sym }
      self
    end

    ##
    # Registers +versions+
    #
    # @param [*Numeric] versions the versions to register
    #
    def versions(*versions)
      registered_versions.push(*versions)
      self
    end

    ##
    # Registers a type alias. This will become a synonym when registering the media type
    #
    # @param [String] alias_name the name of the alias
    #
    def type_alias(alias_name)
      registered_aliases.push(String(alias_name))
      self
    end

    ##
    # Registers a suffix
    #
    # @param [String, Symbol] suffix the suffix to register
    #
    def suffix(suffix)
      registered_suffixes.push(String(suffix).to_sym)
      self
    end

    ##
    # Calculates the aliased media types for a media type
    #
    # @param [Constructable] media_type the media type constructable
    # @return [Array<String>] the resolved aliases
    #
    def aliases(media_type)
      registered_aliases.map { |a| media_type.type(a).to_s }
    end

    def each_combination
      iterable(registered_versions).each do |version|
        registered_views.each do |view, view_opts|
          iterable(registered_suffixes).each do |suffix|
            opts = { view: view_opts }
            yield version, view, suffix, opts
          end
        end
      end
    end

    def iterable(source)
      source.compact.uniq
    end

    def each_resolved
      each_combination do |version, view, suffix, opts|
        media_type = base_media_type.version(version).view(view).suffix(suffix)
        symbol = iterable([opts[:view][:symbol], "v#{version}", suffix]).join('_').to_sym

        yield media_type, symbol
      end
    end
  end
end
