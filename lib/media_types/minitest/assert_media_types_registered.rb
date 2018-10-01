# frozen_string_literal: true

require 'minitest/mock'

module MediaTypes
  module Assertions
    class << self
      def block_exec_instance(instance, &block)
        case block.arity
        when 1, -1
          instance.instance_exec(instance, &block)
        else
          instance.instance_exec(&block)
        end
      end
    end

    def assert_media_types_registered(media_type, &block)
      collector = Collector.new(media_type)
      Assertions.block_exec_instance(collector, &block)
      assert_registered_types(media_type, collector.prepare_verify)
    end

    class Collector
      def initialize(media_type)
        self.media_type = media_type
        self.registers = {}
      end

      def mime_type(mime_type, symbol:, synonyms: [])
        registers[mime_type] = { symbol: symbol, synonyms: synonyms }
      end

      def formatted_mime_type(mime_type_format, &block)
        collector = FormattedCollector.new(mime_type_format, {})
        Assertions.block_exec_instance(collector, &block)
        registers.merge!(collector.to_h)
      end

      def prepare_verify
        expected_types_hash = registers.dup
        expected_types_hash.each do |key, value|
          expected_types_hash[key] = [value[:symbol], Array(value[:synonyms])]
        end

        expected_types_hash
      end

      private

      attr_accessor :media_type, :registers
    end

    class FormattedCollector
      def initialize(format, args = {})
        self.mime_type_format = format
        self.format_args = args
        self.registers = {}
      end

      def version(version, **opts, &block)
        new_format_args = format_args.merge(version: version)
        register(new_format_args, **opts, &block)
      end

      def view(view, **opts, &block)
        new_format_args = format_args.merge(view: view)
        register(new_format_args, **opts, &block)
      end

      def create(**opts, &block)
        view(CREATE_VIEW, **opts, &block)
      end

      def collection(**opts, &block)
        view(COLLECTION_VIEW, **opts, &block)
      end

      def index(**opts, &block)
        view(INDEX_VIEW, **opts, &block)
      end

      def to_h
        Hash(registers)
      end

      private

      attr_accessor :mime_type_format, :registers, :format_args

      def register(new_format_args, symbol: nil, synonyms: [], &block)
        if block_given?
          collector = FormattedCollector.new(mime_type_format, new_format_args)
          Assertions.block_exec_instance(collector, &block)
          registers.merge!(collector.to_h)
        else
          formatted_mime_type_format = format(mime_type_format, **new_format_args)
          registers[formatted_mime_type_format] = { symbol: symbol, synonyms: synonyms }
        end
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def assert_registered_types(media_type, expected_types_hash)
      mock = Minitest::Mock.new
      uncalled = expected_types_hash.dup

      failed = []

      uncalled.length.times do
        mock.expect(:call, nil) do |registerable|
          type = registerable.to_s
          symbol = registerable.to_sym
          synonyms = registerable.synonyms

          options = uncalled.delete(type)
          return true if options && options == [symbol, synonyms] && pass

          failed <<
            MockExpectationError.new(
              format(
                'Call failed to match expectations:' + "\n"\
                '+++ actual [type: %<type>s, symbol: %<symbol>s, synonyms: %<synonyms>s]' + "\n"\
                '--- expected [type: %<type>s, symbol: %<resolved_symbol>s, synonyms: %<resolved_synonyms>s]',
                type: type,
                symbol: symbol,
                synonyms: synonyms,
                resolved_symbol: options&.first,
                resolved_synonyms: options&.last
              )
            )
        end

        false
      end

      MediaTypes.stub(:register, mock) do
        if block_given?
          yield media_type
        else
          media_type.register.flatten
        end
      end

      messages = failed.map(&:message)
      uncalled.each do |type, options|
        messages << format(
          'Call did not occur:' + "\n"\
          '--- expected: [type: %<type>s, symbol: %<resolved_symbol>s, synonyms: %<resolved_synonyms>s]',
          type: type,
          resolved_symbol: options&.first,
          resolved_synonyms: options&.last
        )
      end

      if messages.length.positive?
        flunk messages.join(",\n")
      else
        pass
      end

      assert mock
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
