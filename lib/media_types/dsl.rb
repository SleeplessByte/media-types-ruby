# frozen_string_literal: true

require 'media_types/constructable'
require 'media_types/validations'

require 'media_types/dsl/errors'

module MediaTypes
  module Dsl
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          attr_accessor :media_type_name_for, :media_type_combinations, :media_type_validations, :symbol_keys

          private

          attr_accessor :media_type_constructable, :symbol_base, :media_type_registrar
        end
        base.media_type_combinations = Set.new
      end
    end

    module ClassMethods
      def to_constructable
        raise UninitializedConstructable if media_type_constructable.nil?

        media_type_constructable.dup.tap do |constructable|
          constructable.__setobj__(self)
        end
      end

      def symbol_keys?
        if symbol_keys.nil?
          MediaTypes.get_key_expectation(self)
        else
          symbol_keys
        end
      end

      def string_keys?
        !symbol_keys?
      end

      def valid?(output, **opts)
        to_constructable.valid?(output, **opts)
      end

      def valid_unsafe?(output, media_type = to_constructable, **opts)
        opts[:expected_key_type] = string_keys? ? String : Symbol
        validations.find(media_type).valid?(output, backtrace: ['.'], **opts)
      end

      def validate!(output, **opts)
        target_scheme = media_type_validations.scheme
        assert_sane! unless target_scheme.asserted_sane?
        to_constructable.validate!(output, **opts)
      end

      def validate_unsafe!(output, media_type = to_constructable, **opts)
        opts[:expected_key_type] = string_keys? ? String : Symbol
        validations.find(media_type).validate(output, backtrace: ['.'], **opts)
      end

      def validatable?(media_type = to_constructable)
        return false unless validations

        resolved = validations.find(media_type, -> { nil })

        !resolved.nil?
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

      def identifier_format
        self.media_type_name_for = proc do |type:, view:, version:, suffix:|
          yield(type: type, view: view, version: version, suffix: suffix)
        end
      end

      def identifier
        to_constructable.to_s
      end

      def available_validations
        media_type_combinations.map do |a|
          _, view, version = a
          view(view).version(version)
        end
      end

      def schema_for(constructable)
        validations.find(constructable)
      end

      def assert_sane!
        media_type_validations.run_queued_fixture_checks(symbol_keys?)
      end

      private

      def use_name(name)
        if media_type_name_for.nil?
          self.media_type_name_for = proc do |type:, view:, version:, suffix:|
            resolved_org = nil
            if defined?(organisation)
              resolved_org = organisation
            else
              resolved_org = MediaTypes.get_organisation(self)

              raise format('Implement the class method "organisation" in %<klass>s or specify a global organisation using MediaTypes::set_organisation', klass: self) if resolved_org.nil?
            end
            raise ArgumentError, 'Unable to create a name for a schema with a nil name.' if type.nil?
            raise ArgumentError, 'Unable to create a name for a schema with a nil organisation.' if resolved_org.nil?

            result = "application/vnd.#{resolved_org}.#{type}"
            result += ".v#{version}" unless version.nil?
            result += ".#{view}" unless view.nil?
            result += "+#{suffix}" unless suffix.nil?
            result
          end
        end
        self.media_type_constructable = Constructable.new(self, type: name)
      end

      def expect_string_keys
        raise KeyTypeExpectationError, 'Key expectation already set' unless symbol_keys.nil?

        self.symbol_keys = false
      end

      def expect_symbol_keys
        raise KeyTypeExpectationError, 'Key expectation already set' unless symbol_keys.nil?

        self.symbol_keys = true
      end

      def validations(&block)
        unless block_given?
          raise "No validations defined for #{name}" if media_type_validations.nil?

          return media_type_validations
        end
        self.media_type_validations = Validations.new(to_constructable, &block)

        self
      rescue UninitializedConstructable => e
        raise e.class, 'Have you called `use_name(name)` before the validations?'
      end
    end
  end
end
