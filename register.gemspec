# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'register/version'

Gem::Specification.new do |spec|
  spec.name          = 'register'
  spec.version       = Register::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = ['kigster@gmail.com']

  spec.summary = 'This is a simple module-level registry for application globals. Use it to wrap global connection pools, memcached connections, redis, even database connections, and register them within a top-level namespace module of your application. For example, instead of doing Rails.cache you could be doing MyApp.rails_cache or MyApp.redis_cache, etc.'
  spec.description   = 'This is a simple module-level registry for application globals. Use it to wrap global connection pools, memcached connections, redis, even database connections, and register them within a top-level namespace module of your application. For example, instead of doing Rails.cache you could be doing MyApp.rails_cache or MyApp.redis_cache, etc.'
  spec.homepage      = 'https://github.com/kigster/register'
  spec.license       = 'MIT'
  spec.files         = `git ls-files`.split($\).reject{ |f| f.match(%r{^(doc|spec|coverage|pkg)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'irbtools'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'yard-rspec'
end
