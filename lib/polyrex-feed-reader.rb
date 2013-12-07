#!/usr/bin/env ruby

# file: polyrex-feed-reader.rb

require 'nokogiri'
require 'rss_to_dynarex'
require 'polyrex'

class PolyrexFeedReader

  def initialize(polyrex)

    @polyrex = polyrex

  end  

  def fetch_feeds()

    feeds = @polyrex.xpath('//column/records/feed/summary')

    feeds.each do |feed|

      puts "fetching %s ..." % feed.text('rss_url').inspect

      rtd = RSStoDynarex.new feed.text('rss_url')
      dynarex = rtd.to_dynarex
      dynarex.save "%s.xml" % feed.text('title')\
                          .downcase.gsub(/\s/,'').gsub('-','_')
    end
  end

  def refresh

    @polyrex.records.each do |column|

      column.records.each do |feed|

        filename = "%s.xml" % feed.title\
                            .downcase.gsub(/\s/,'').gsub('-','_')

        d = Dynarex.new filename

        d.to_h[0..2].each.with_index do |x, i|

          h = {title: x[:title]}

          if i == 0 then

            raw_desc = CGI.unescapeHTML(x[:description]).gsub(/<\/?[^>]*>/, "")
            desc = raw_desc.length > 300 ? raw_desc[0..296] + ' ...' : raw_desc
            h[:description] = desc
          end

          feed.create.item h
        end

      end
    end
  end

  alias update_doc refresh

  def save_html(filepath='feeds.html')

    lib = File.dirname(__FILE__)
    xsl_buffer = File.read(lib + '/feeds.xsl')
    #xsl_buffer = File.read('feeds.xsl')

    xslt  = Nokogiri::XSLT(xsl_buffer)
    html = xslt.transform(Nokogiri::XML(@polyrex.to_xml)).to_s
    File.write filepath, html
  end

  def save_xml(filepath='feeds.xml')
    @polyrex.save filepath, pretty: true
  end

end

if __FILE__ == $0 then

  pfr = PolyrexFeedReader.new(px)
  pfr.fetch_feeds
  pfr.update_doc
  pfr.save_xml 'feeds.xml'
  pfr.save_html 'feeds.html'

end