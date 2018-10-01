# frozen_string_literal: true

require 'delegate'

require 'media_types/version'
require 'media_types/hash'
require 'media_types/object'
require 'media_types/scheme'
require 'media_types/dsl'

module MediaTypes
  # Shortcut used by #collection to #view('collection')
  COLLECTION_VIEW = 'collection'

  # Shortcut used by #index to #view('index')
  INDEX_VIEW = 'index'

  # Shortcut used by #create to #view('create')
  CREATE_VIEW = 'create'

  module_function

  ##
  # Called when Registerar#register is called
  # @param [Registerable] registerable
  def register(registerable)
    require 'action_dispatch/http/mime_type'

    mime_type = registerable.to_s
    symbol = registerable.to_sym
    synonyms = registerable.aliases

    Mime::Type.register(mime_type, symbol, synonyms)
  end
end


