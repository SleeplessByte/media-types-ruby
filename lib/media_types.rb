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
    @expect_symbol_keys = false
  end

  def self.expect_symbol_keys
    @expect_symbol_keys = true
  end

  def self.expecting_symbol_keys?
    @expect_symbol_keys
  end

  # Keep track of modules setting their key expectations
  def self.set_key_expectation(mod, _expect_symbol_keys)
    @organisation_key_expectations ||= {}

    # Check if this key is already set, if so, we need to throw an error
    raise 'Module already has a key expectation set' if @organisation_key_expectations[mod.name]

    # If it's not set already, register it now
    @organisation_key_expectations[mod.name] = expect_symbol_keysend
  end

  def demodulize(mod)
    mod = mod.to_s
    if (i = mod.rindex('::'))
      mod[(i + 2)..-1]
    else
      mod
    end
  end

  def self.get_key_expectation(mod)
    return nil if mod.name == 'MediaTypes' # Need to figure out a proper base case.

    current_module = mod.name

    # Exact match
    @organisation_key_expectations[current_module]
    # Return exact match

    # If none is found, we have to get the parent module and do a recursive call
    module_array = target_module.name.split('::')
    current_module = module_array.pop
    parent_module = module_array.join('::')
    # Recursive call get_key_expectation(parent_module)
  end

  def self.get_organisation(mod)
    name = mod.name
    prefixes = @organisation_prefixes.keys.select { |p| name.start_with? p }
    return nil unless prefixes.any?

    best = prefixes.max_by { |p| p.length }

    @organisation_prefixes[best]
  end
end
