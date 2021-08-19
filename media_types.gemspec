# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'media_types/version'

Gem::Specification.new do |spec|
  spec.name          = 'media_types'
  spec.version       = MediaTypes::VERSION
  spec.authors       = ['Derk-Jan Karrenbeld', 'Max Maton']
  spec.email         = ['derk-jan+github@karrenbeld.info', 'info@maxmaton.nl']

  spec.summary       = 'Library to create media type definitions, schemes and validations'
  spec.description   = 'Media Types as mime types are not easily supported by frameworks such as rails. '
  spec.homepage      = 'https://github.com/SleeplessByte/media-types-ruby'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print', '1.8'
  spec.add_development_dependency 'bundler', '>= 2'
  spec.add_development_dependency 'minitest', '5.11'
  spec.add_development_dependency 'minitest-reporters', '1.0.19'
  spec.add_development_dependency 'oj', '3.7.6'
  spec.add_development_dependency 'rake', '12.3.1'
  spec.add_development_dependency 'simplecov', '0.16.1'
end
