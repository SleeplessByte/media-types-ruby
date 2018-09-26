# frozen_string_literal: true

require 'media_types/version'
require 'media_types/base'
require 'media_types/scheme'

require 'delegate'

module MediaTypes
  COLLECTION_VIEW = 'collection'
  INDEX_VIEW = 'index'
  CREATE_VIEW = 'create'

  module_function

  def register(mime_type:, symbol: nil, synonyms: [])
    require 'action_dispatch/http/mime_type'
    Mime::Type.register(mime_type, symbol, synonyms)
  end

  class Object < SimpleDelegator
    def class
      __getobj__.class
    end

    def ===(other)
      __getobj__ === other # rubocop:disable Style/CaseEquality
    end

    def blank?
      if __getobj__.respond_to?(:blank?)
        return __getobj__.blank?
      end

      # noinspection RubySimplifyBooleanInspection
      __getobj__.respond_to?(:empty?) ? !!__getobj__.empty? : !__getobj__ # rubocop:disable Style/DoubleNegation
    end

    def present?
      !blank?
    end
  end

  class Hash < SimpleDelegator
    def class
      __getobj__.class
    end

    def ===(other)
      __getobj__ === other # rubocop:disable Style/CaseEquality
    end

    def slice(*keep_keys)
      if __getobj__.respond_to?(:slice)
        return __getobj__.slice(*keep_keys)
      end

      h = {}
      keep_keys.each { |key| h[key] = fetch(key) if key?(key) }
      h
    end
  end
end


