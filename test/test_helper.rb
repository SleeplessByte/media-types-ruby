# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(File.join('..', 'lib'), __dir__)

# Loads gems from gemfile so you don't need bundle exec
ENV['BUNDLE_GEMFILE'] ||= File.expand_path(File.join('..', 'Gemfile'), __dir__)
require 'bundler/setup'

if ENV['COVERAGE']
  # Setup for coverage
  require 'simplecov'

  SimpleCov.start do
    add_filter 'test'
    track_files '{lib}/**/*.rb'
  end

  if ENV['CIRCLE_ARTIFACTS']
    dir = File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
    SimpleCov.coverage_dir(dir)
  end
end
require 'media_types'

# Reports
require 'minitest/reporters'
Minitest::Reporters.use!

# Run at exit
require 'minitest/autorun'
require 'media_types/testing/assertions'

module Minitest
  class Test < Minitest::Runnable
    include MediaTypes::Testing::Assertions

    def self.create_specification_tests_for(mediatype)
      define_method "test_mediatype_specification_of_#{mediatype.name}" do
        assert_mediatype mediatype
      end
    end
  end
end
