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
          attr_accessor :media_type_name_for, :media_type_combinations

          private

          attr_accessor :media_type_constructable, :symbol_base, :media_type_registrar, :media_type_validations
        end
      end
    end

    module ClassMethods

      def to_constructable
        media_type_constructable.dup.tap do |constructable|
          constructable.__setobj__(self)
        end
      end

      def valid?(output, **opts)
        to_constructable.valid?(output, **opts)
      end

      def valid_unsafe?(output, media_type = to_constructable, **opts)
        validations.find(media_type).valid?(output, backtrace: ['.'], **opts)
      end
      
      def validate!(output, **opts)
        to_constructable.validate!(output, **opts)
      end

      def validate_unsafe!(output, media_type = to_constructable, **opts)
        validations.find(media_type).validate(output, backtrace: ['.'], **opts)
      end

      def validatable?(media_type = to_constructable)
        return false unless validations

        validations.find(media_type, -> { nil })
      end

      def register
        registrations.to_a.map do |registerable|
          MediaTypes.register(registerable)
          registerable
        end
      end
      
      def view(v)
        to_constructable.view(v)
      end
      def version(v)
        to_constructable.version(v)
      end
      def suffix(s)
        to_constructable.suffix(s)
      end

      def identifier_format
        self.media_type_name_for = Proc.new do |type:, view:, version:, suffix:|
          yield(type: type, view: view, version: version, suffix: suffix)
        end
      end

      def identifier
        to_constructable.to_s
      end

      def available_validations
        self.media_type_combinations.map do |a|
          _, view, version, suffix = a
          view(view).version(version).suffix(suffix)
        end
      end

      private

      def name(name, defaults: {})
        if self.media_type_name_for.nil?
          self.media_type_name_for = Proc.new do |type:, view:, version:, suffix:|
            raise format('Implement the class method "organisation" in %<klass>s', klass: self) unless defined?(:organisation)
            raise ArgumentError, 'Unable to create a name for a schema with a nil name.' if type.nil?
            raise ArgumentError, 'Unable to create a name for a schema with a nil organisation.' if organisation.nil?

            result = "application/vnd.#{organisation}.#{type}"
            result += ".v#{version}" unless version.nil?
            result += ".#{view}" unless view.nil?
            result += "+#{suffix}" unless suffix.nil?
            result
          end
        end
        self.media_type_constructable = Constructable.new(self, type: name).suffix(defaults.fetch('suffix') { nil })
      end

      def defaults(&block)
        return media_type_constructable unless block_given?
        self.media_type_constructable = Defaults.new(to_constructable, &block).to_constructable

        self
      end

      def registrations(symbol = nil, &block)
        return media_type_registrar unless block_given?
        self.media_type_registrar = Registrar.new(self, symbol: symbol, &block)

        self
      end

      def validations(&block)
        return media_type_validations unless block_given?
        self.media_type_validations = Validations.new(to_constructable, &block)

        self
      end
    end
  end
end
