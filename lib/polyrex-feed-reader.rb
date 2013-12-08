#!/usr/bin/env ruby

# file: polyrex-feed-reader.rb

require 'nokogiri'
require 'rss_to_dynarex'
require 'polyrex'

class Fixnum

  def ordinal
    self.to_s + ( (10...20).include?(self) ? 'th' : 
        %w{ th st nd rd th th th th th th }[self % 10] )
  end

  def seconds() self end
  def minutes() self * 60 end
  def hours()   self * seconds * 60 end
  def days()    self *   hours * 24 end
  def weeks()   self *    days * 7  end
  def months()  self *    days * 30 end
  alias second seconds; alias hour hours; alias minute minutes
  alias day days; alias week weeks; alias month months

end

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

  def datetimestamp()

    hour, minutes, day, year = Time.now.to_a.values_at 2,1,3,5
    meridian, month = Time.now.strftime("%p %b").split
    "%d:%s%s %s %s %s" % [hour, minutes, meridian.downcase, \
                            day.ordinal, month, year]
  end

  def refresh

    @polyrex.records.each do |column|

      column.records.each do |feed|

        filename = "%s.xml" % feed.title\
                            .downcase.gsub(/\s/,'').gsub('-','_')

        d = Dynarex.new filename
        feed.last_accessed = datetimestamp()
        feed.last_modified = datetimestamp() if feed.last_modified.empty?

        items = d.to_h[0..2]

        puts 'items.first[:title] '  + items.first[:title].inspect
        puts 'feed.item[0].title '  + feed.item[0].title.inspect

        if feed.records.length > 0 and \
                                items.first[:title] == feed.item[0].title then
          feed.recent = recency(feed.last_modified)
          next 
        end

        feed.recent = '1hot'
        feed.records.remove_all
        items.each.with_index do |x, i|

          h = {title: x[:title]}

          if i == 0 then

            raw_desc = CGI.unescapeHTML(x[:description]).gsub(/<\/?[^>]*>/, "")
            desc = raw_desc.length > 300 ? raw_desc[0..296] + ' ...' : raw_desc
            h[:description] = desc
          end

          feed.create.item h
        end

        feed.last_modified = datetimestamp()

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

  private

  def recency(time)

    case (Time.now - Time.parse(time))
      when 1.second..5.minutes then '1hot'
      when 5.minutes..4.hours then '2warm'
      when 4.hours..1.week then '3cold'
      when 1.week..1.month then '4coldx1week'
      when 1.month..6.months then '5coldx1month'
      else '6coldx6months'
    end
  end

end

if __FILE__ == $0 then

  pfr = PolyrexFeedReader.new(px)
  pfr.fetch_feeds
  pfr.refresh
  pfr.save_xml 'feeds.xml'
  pfr.save_html 'feeds.html'

end