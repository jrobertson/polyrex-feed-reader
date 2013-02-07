Gem::Specification.new do |s|
  s.name = 'polyrex-feed-reader'
  s.version = '0.3.2'
  s.summary = 'polyrex-feed-reader'
    s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency('polyrex')
  s.add_dependency('builder')
  s.add_dependency('chronic')
 
  s.signing_key = '../privatekeys/polyrex-feed-reader.pem'
  s.cert_chain  = ['gem-public_cert.pem']
end
