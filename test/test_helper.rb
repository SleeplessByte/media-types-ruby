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
require 'minitest/ci' if ENV['CI']
require 'minitest/autorun'
require_relative './assertions'

class Minitest::Test < Minitest::Runnable
  include Assertions::MediaTypes
end
