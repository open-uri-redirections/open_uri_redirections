# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'open_uri_redirections/version'

Gem::Specification.new do |gem|
  gem.name          = 'open_uri_redirections'
  gem.version       = OpenUriRedirections::VERSION
  gem.authors       = ['Jaime Iniesta', 'Gabriel Cebrian', 'Felix C. Stegerman']
  gem.email         = %w(jaimeiniesta@gmail.com gabceb@gmail.com flx@obfusk.net)
  gem.description   = 'OpenURI patch to allow HTTP <==> HTTPS redirections'
  gem.summary       = 'OpenURI patch to allow HTTP <==> HTTPS redirections'
  gem.homepage      = 'https://github.com/open-uri-redirections/open_uri_redirections'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files    = `git ls-files -- spec`.split($INPUT_RECORD_SEPARATOR)
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec',   '~> 3.1.0'
  gem.add_development_dependency 'fakeweb', '~> 1.3.0'
  gem.add_development_dependency 'rake',    '~> 10.4.0'
end
