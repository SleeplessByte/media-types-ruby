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

  def self.expect_string_keys(mod)
    set_key_expectation(mod, false)
  end

  def self.expect_symbol_keys(mod)
    set_key_expectation(mod, true)
  end

  def self.expecting_symbol_keys?(mod)
    get_key_expectation(mod)
  end

  # Keep track of modules setting their key expectations
  def self.set_key_expectation(mod, expect_symbol_keys)
    @key_expectations ||= {}

    raise format('%<mod>s already has a key expectation set', mod: mod.name) if @key_expectations[mod.name]

    @key_expectations[mod.name] = expect_symbol_keys
  end

  def self.get_key_expectation(mod)
    modules = mod.name.split('::')
    expect_symbol = nil

    while modules.any? && expect_symbol.nil?
      current_module = modules.join('::')
      expect_symbol = @key_expectations[current_module]
      modules = current_module.split('::')
      modules.pop
    end

    expect_symbol
  end

  def self.get_organisation(mod)
    name = mod.name
    prefixes = @organisation_prefixes.keys.select { |p| name.start_with? p }
    return nil unless prefixes.any?

    best = prefixes.max_by { |p| p.length }

    @organisation_prefixes[best]
  end
end
