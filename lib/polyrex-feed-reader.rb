#!/usr/bin/env ruby

# file: polyrex-feed-reader.rb

require 'nokogiri'
require 'rss_to_dynarex'
require 'polyrex'


MINUTE = 60
HOUR = MINUTE * 60
DAY = HOUR * 24
WEEK = DAY * 7
MONTH = DAY * 30


class PolyrexFeedReader

  def initialize(polyrex)

    @polyrex = polyrex

  end  

  def fetch_feeds()

    feeds = @polyrex.xpath('//column/records/section/records/feed/summary')

    feeds.each do |feed|

      puts "fetching %s " % feed.text('rss_url').inspect

      rtd = RSStoDynarex.new feed.text('rss_url')
      dynarex = rtd.to_dynarex
      dynarex.save "%s.xml" % feed.text('title')\
                          .downcase.gsub(/\s/,'').gsub(/\W/,'_')
    end
  end

  def refresh

    @polyrex.records.each do |column|

      column.records.each do |section| 
   
        section.records.each do |feed|

          filename = "%s.xml" % feed.title\
                              .downcase.gsub(/\s/,'').gsub(/\W/,'_')
          puts 'filename : ' + filename.inspect
          d = Dynarex.new filename
          feed.last_accessed = datetimestamp()
          feed.last_modified = datetimestamp() if feed.last_modified.empty?

          items = d.to_h[0..2]

          if feed.records.length > 0 and \
                                  items.first[:title] == feed.item[0].title then
            feed.recent = recency(feed.last_modified)
            next 
          end

          feed.recent = '1hot'
          feed.records.remove_all
          items.each.with_index do |x, i|

            h = {title: x[:title], link: x[:link]}

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
  end

  alias update_doc refresh

  def save_css(filepath='feeds.css')

    lib = File.dirname(__FILE__)
    #xsl_buffer = File.read(lib + '/feeds.css')
    css_buffer = File.read('feeds.css')

    File.write filepath, css_buffer
  end

  def save_html(filepath='feeds.html')

    lib = File.dirname(__FILE__)
    #xsl_buffer = File.read(lib + '/feeds.xsl')
    xsl_buffer = File.read('feeds.xsl')

    xslt  = Nokogiri::XSLT(xsl_buffer)
    html = xslt.transform(Nokogiri::XML(@polyrex.to_xml)).to_s
    File.write filepath, html
  end

  def save_xml(filepath='feeds.xml')
    @polyrex.save filepath, pretty: true
  end

  private

  def datetimestamp()

    hour, minutes, day, year = Time.now.to_a.values_at 2,1,3,5
    meridian, month = Time.now.strftime("%p %b").split
    "%d:%02d%s %s %s %s" % [hour, minutes, meridian.downcase, \
                            ordinal(day), month, year]
  end

  def ordinal(i)
    i.to_s + ( (10...20).include?(i) ? 'th' : 
        %w{ th st nd rd th th th th th th }[i % 10] )
  end


  def recency(time)

    case (Time.now - Time.parse(time))
      when second(1)..minutes(5) then '1hot'
      when minutes(5)..hours(4) then '2warm'
      when hours(4)..week(1) then '3cold'
      when week(1)..month(1) then '4coldx1week'
      when month(1)..months(6) then '5coldx1month'
      else '6coldx6months'
    end
  end


  def seconds(i) i end
  def minutes(i) i * MINUTE end
  def hours(i)   i * HOUR   end
  def days(i)    i * DAY    end
  def weeks(i)   i * WEEK   end
  def months(i)  i * MONTH  end
  alias second seconds; alias hour hours; alias minute minutes
  alias day days; alias week weeks; alias month months

end

if __FILE__ == $0 then

  pfr = PolyrexFeedReader.new(px)
  pfr.fetch_feeds
  pfr.refresh
  pfr.save_xml  'feeds.xml'
  pfr.save_html 'feeds.html'
  pfr.save_css  'feeds.css'

end