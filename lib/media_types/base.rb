# frozen_string_literal: true

require 'media_types/base/collector'
require 'media_types/constructable_mime_type'
require 'media_types/scheme'

module MediaTypes
  class Base

    class << self
      ##
      # Registers all configured mime types
      #
      def register(**overrides)
        override_version = overrides.delete(:version)
        if override_version
          self.versions_ = { override_version => { scheme: (overrides.delete(:scheme) || current_scheme_) } }
        end

        Array(registers_).map do |registered|
          resolvable = registered.merge(Hash(overrides))
          mime_type = construct_mime_type(resolvable)

          resolve_versions(resolvable) do |version, symbol:|
            MediaTypes.register(
              mime_type: mime_type.version(version).to_s,
              symbol: symbol,
              synonyms: versioned_synonyms(version, resolvable)
            )
            symbol
          end
        end.flatten.compact
      end

      ##
      # Get the constructable mime type for this class
      #
      # @return [ConstructableMimeType]
      #
      def mime_type(type: type_, version: current_version_, suffix: suffix_, view: nil)
        ConstructableMimeType.new(self, format: base_format, version: version, suffix: suffix, type: type, view: view)
      end

      def current_version
        current_version_
      end

      def valid?(output, version: current_version, **opts)
        scheme = version_scheme(version: version)
        !scheme || scheme.valid?(output, backtrace: ['.'], **opts)
      end

      def validate!(output, version: current_version, **opts)
        scheme = version_scheme(version: version)
        scheme.validate(output, backtrace: ['.'], **opts)
      end

      protected

      attr_accessor :type_, :suffix_, :registers_, :versions_, :type_aliases_, :current_version_, :current_scheme_

      def base_format
        NotImplementedError.new('Implementors of MediaType::Base must override base_format')
      end

      ##
      # Configure the media type
      #
      # @param [String] media_type the +type+ part of the media type
      # @param [Symbol, String, NilClass] suffix the +suffix+ part of the media type
      # @param [Array<String>] aliases the aliases of +media_type+
      # @param [Number, String] version the latest version
      #
      def media_type(media_type, suffix: nil, aliases: [], current_version: nil, version: current_version, &block)
        self.type_ = media_type
        self.type_aliases_ = aliases
        self.suffix_ = suffix

        self.current_version_ = version
        self.current_scheme_ = current_scheme(&block)
      end

      def current_scheme(&block)
        scheme = Scheme.new
        scheme.instance_exec(&block) if block_given?

        self.current_scheme_ = scheme
      end

      ##
      # Start registering media types
      #
      # @param [Symbol] opts optional symbol
      # @option options [Symbol] symbol the symbol to register as if not given by +opts+
      # @option options [Number] version the version to register for defaults to +current_version_+
      # @option options [String, NilClass] view the view of the registered type
      # @option options [String] synonyms synonyms to resolve to the same type
      #
      # @yieldparam [Collector] the collector to collect views for the media type
      #
      def register_types(*opts, **options, &block)
        version = options.delete(:version)
        symbol_suffix = options.delete(:symbol_suffix)

        register_type(*opts, **options)
        register_version(version || current_version_, symbol_suffix: symbol_suffix, scheme: current_scheme_)

        return unless block_given?
        block_collector(&block)
      end

      def register_additional_versions(&block)
        block_collector(&block)
      end

      private

      def block_collector(&block)
        collector = Collector.new(self)

        case block.arity
        when 1, -1
          collector.instance_exec(collector, &block)
        else
          collector.instance_exec(&block)
        end
      end

      # @param [Symbol] opts optional symbol
      # @param [Symbol] symbol the symbol to register as if not given by +opts+
      # @param [String, NilClass] view the view of the registered type
      # @param [String] synonyms synonyms to resolve to the same type
      # rubocop:disable Metrics/ParameterLists
      def register_type(*opts, suffix: suffix_, view: nil, symbol: nil, synonyms: [], version: nil)
        symbol = opts&.first || symbol
        self.registers_ = Array(registers_).push(
          symbol: symbol,
          view: view,
          synonyms: synonyms,
          suffix: suffix,
          pinned_version: version
        )
      end
      # rubocop:enable Metrics/ParameterLists

      def construct_mime_type(type: type_, **resolvable)
        mime_type(type: type, **MediaTypes::Hash.new(resolvable).slice(:version, :view, :suffix))
      end

      def synonyms(resolvable)
        aliases = type_aliases_.map { |type_alias| construct_mime_type(type: type_alias, **resolvable) }

        Array(resolvable[:synonyms]).concat(aliases)
      end

      def register_version(version, symbol_suffix: :"_v#{version}", scheme: Scheme.new, &block)
        scheme.instance_exec(&block) if block_given?

        self.versions_ = Hash(versions_).merge(
          version => {
            symbol_suffix: symbol_suffix,
            scheme: scheme
          }
        )
      end

      def resolve_versions(**resolvable)
        pinned_version = resolvable[:pinned_version]

        versions.map do |version, opts|
          next if pinned_version && pinned_version != version
          yield version, symbol: :"#{resolvable.fetch(:symbol)}#{opts[:symbol_suffix]}"
        end
      end

      def versioned_synonyms(version, resolvable)
        synonyms(resolvable).map do |synonym|
          synonym.is_a?(String) ? synonym : synonym.version(version).to_s
        end.uniq
      end

      def versions
        { current_version => { scheme: current_scheme_ } }.merge(Hash(versions_))
      end

      def version_scheme(version:)
        version_data = versions[version]
        return nil unless version_data
        version_data[:scheme] || nil
      end
    end
  end
end
