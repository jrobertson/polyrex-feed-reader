Gem::Specification.new do |s|
  s.name = 'polyrex-feed-reader'
  s.version = '0.5.14'
  s.summary = 'Fetches RSS feeds from a Polyrex file and displays each feed summary on an HTML page'
  s.authors = ['James Robertson']
  s.files = Dir[
      'lib/**/*.rb', 
      'lib/feeds.xsl',
      'lib/feeds.css', 
      'lib/dynarex-feed.xsl', 
      'lib/dynarex-feed.css',
      'lib/latest.xsl',
      'lib/opml-feeds.xsl'
  ]
  s.add_dependency('polyrex')
  s.add_dependency('rss_to_dynarex')
  s.add_dependency('nokogiri')
  s.signing_key = '../privatekeys/polyrex-feed-reader.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/polyrex-feed-reader'
end
