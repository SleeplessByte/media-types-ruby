# frozen_string_literal: true

require 'delegate'

require 'media_types/version'
require 'media_types/hash'
require 'media_types/object'
require 'media_types/scheme'
require 'media_types/dsl'
require 'media_types/minitest/assert_media_type_format'
require 'media_types/minitest/test_factory'

require 'media_types/views'

module MediaTypes
  def self.set_organisation(mod, organisation)
    @organisation_prefixes ||= {}
    @organisation_prefixes[mod.name] = organisation
  end

  def self.expect_string_keys
    @@expect_symbol_keys =  false
  end

  def self.expect_symbol_keys
    @@expect_symbol_keys =  true
  end

  def self.get_organisation(mod)
    name = mod.name
    prefixes = @organisation_prefixes.keys.select { |p| name.start_with? p }
    return nil unless prefixes.any?

    best = prefixes.max_by { |p| p.length }

    @organisation_prefixes[best]
  end
end
