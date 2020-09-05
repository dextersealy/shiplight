# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shiplight/version'

Gem::Specification.new do |spec|
  spec.name = 'shiplight'
  spec.version = Shiplight::VERSION
  spec.authors = ['Dexter Sealy']
  spec.email = ['dextersealy@gmail.com']
  spec.required_ruby_version = '>= 2.4'

  spec.summary = 'Display Codeship status with blink(1) indicator light'
  # spec.description   = 'Write a longer description or delete this line.'
  spec.homepage = 'https://github.com/dextersealy/ship-light'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this section
  # to allow pushing to any host.

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'bin'
  spec.executables = ['shiplight']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'httparty', '~> 0.15'
  spec.add_runtime_dependency 'inifile', '~> 3.0'
  spec.add_runtime_dependency 'rb-blink1', '~> 0.0'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
