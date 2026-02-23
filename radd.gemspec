$:.push File.expand_path('../lib', __FILE__)

require 'radd/version'

Gem::Specification.new do |s|
  s.name          = 'radd'
  s.version       = Radd::VERSION
  s.date          = '2026-02-23'
  s.summary       = 'Roll your own dynamic DNS'
  s.description   = 'Minimal dynamic DNS service'
  s.authors       = ['Matthias Grosser']
  s.email         = 'mtgrosser@gmx.net'
  s.files         = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', 'README.md', 'CHANGELOG']
  s.require_path  = 'lib'
  s.homepage      = 'https://github.com/mtgrosser/radd'  
  s.license       = 'MIT'

  s.executables << 'radd'

  s.required_ruby_version = '>= 4.0.0'

  s.add_dependency 'rake'
  s.add_dependency 'optparse'
  s.add_dependency 'async-http'
  s.add_dependency 'protocol-rack'
  s.add_dependency 'async-dns'

  s.add_development_dependency 'irb'
  s.add_dependency 'rack'
  s.add_dependency 'sequel'
  s.add_dependency 'sqlite3'
  s.add_dependency 'bcrypt'
end
