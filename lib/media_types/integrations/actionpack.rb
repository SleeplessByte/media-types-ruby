# frozen_string_literal: true

require 'action_dispatch/http/mime_type'

module MediaTypes
  module ActionPackIntegration

    module_function

    def register(registerable)
      mime_type = registerable.to_s
      symbol = registerable.to_sym
      synonyms = registerable.aliases

      Mime::Type.register(mime_type, symbol, synonyms)
    end
  end

  integrate ActionPackIntegration
end

