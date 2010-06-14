Gem::Specification.new do |s|
  s.name = 'polyrex-feed-reader'
  s.version = '0.1.3'
  s.summary = 'polyrex-feed-reader'
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('polyrex')
  s.add_dependency('builder')
  s.add_dependency('chronic')

end
