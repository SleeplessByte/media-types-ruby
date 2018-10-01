# frozen_string_literal: true

require 'media_types/constructable'
require 'media_types/defaults'
require 'media_types/registrar'
require 'media_types/validations'

module MediaTypes
  module Dsl
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          private

          attr_accessor :media_type_constructable, :symbol_base, :media_type_registrar, :media_type_validations
        end
      end
    end

    module ClassMethods

      def to_constructable
        media_type_constructable.dup
      end

      def valid?(output, media_type = to_constructable, **opts)
        validations.find(String(media_type)).valid?(output, backtrace: ['.'], **opts)
      end

      def validate!(output, media_type = to_constructable, **opts)
        validations.find(String(media_type)).validate(output, backtrace: ['.'], **opts)
      end

      def register
        registrations.to_a.map do |registerable|
          MediaTypes.register(registerable)
          registerable
        end
      end

      private

      def media_type(name, defaults: {})
        self.media_type_constructable =
          Constructable.new(self, format: base_format, type: name)
                       .version(defaults.fetch(:version) { nil })
                       .suffix(defaults.fetch(:suffix) { nil })
                       .view(defaults.fetch(:view) { nil })
      end

      def defaults(&block)
        self.media_type_constructable = Defaults.new(to_constructable, &block).to_constructable
      end

      def registrations(symbol = nil, &block)
        self.media_type_registrar = media_type_registrar || Registrar.new(self, symbol: symbol, &block)
      end

      def validations(&block)
        self.media_type_validations = media_type_validations || Validations.new(to_constructable, &block)
      end
    end
  end
end
