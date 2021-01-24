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

  # Keep track of modules setting their key expectations
  def self.set_key_expectation(mod, expect_symbol_keys)
    @key_expectations ||= {}

    raise format('%<mod>s already has a key expectation set', mod: mod.name) unless @key_expectations[mod.name].nil?
    raise format('Unable to change key type expectation for %<mod>s since its current expectation is already used', mod: mod.name) if @key_expectations_used && @key_expectations_used[mod.name]

    @key_expectations[mod.name] = expect_symbol_keys
  end

  SYMBOL_KEYS_DEFAULT = true

  def self.get_key_expectation(mod)
    @key_expectations_used ||= {}

    if @key_expectations.nil?
      @key_expectations_used[mod] = true
      return SYMBOL_KEYS_DEFAULT
    end

    modules = mod.name.split('::')
    expect_symbol = nil
    current_module = nil

    while modules.any? && expect_symbol.nil?
      current_module = modules.join('::')
      expect_symbol = @key_expectations[current_module]
      modules = current_module.split('::')
      modules.pop
    end

    @key_expectations_used[current_module] = true if current_module

    expect_symbol.nil? ? SYMBOL_KEYS_DEFAULT : expect_symbol
  end

  def self.get_organisation(mod)
    name = mod.name
    prefixes = @organisation_prefixes.keys.select { |p| name.start_with? p }
    return nil unless prefixes.any?

    best = prefixes.max_by { |p| p.length }

    @organisation_prefixes[best]
  end
end
