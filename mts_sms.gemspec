version = "0.0.1"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'mts_sms'
  s.version = version
  s.summary = 'Sending sms with MTS m2m.'
  s.description = 'Sending sms with MTS m2m SOAP API.'

  s.files = Dir['README.md', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.author = 'Zykov Nikolay'
  s.email = 'nzykov@voltmobi.com'
  s.homepage = 'https://github.com/Exact1990/mts_sms'

  s.add_dependency('savon', '= 1.2.0')
  s.add_dependency('activesupport', '>=2.3.4')
  s.add_dependency('feedzirra')

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
end