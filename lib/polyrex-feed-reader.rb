#!/usr/bin/env ruby

# file: polyrex-feed-reader.rb

require 'nokogiri'
require 'rss_to_dynarex'
require 'polyrex'
require 'time'


MINUTE = 60
HOUR = MINUTE * 60
DAY = HOUR * 24
WEEK = DAY * 7
MONTH = DAY * 30


class PolyrexFeedReader

  def initialize(polyrex)

    @polyrex = polyrex

  end  

  def feeds_to_html()

    feeds do |feed, filename|

      next if nothing_new? feed
      puts "transforming %s " % filename
      xsltproc 'dynarex-feed.xsl', File.read(filename), filename.sub(/xml$/,'html')
    end
  end

  def fetch_feeds()

w3centities =<<EOF
<!DOCTYPE stylesheet [
  <!ENTITY % w3centities-f PUBLIC "-//W3C//ENTITIES Combined Set//EN//XML"
      "http://www.w3.org/2003/entities/2007/w3centities-f.ent">
  %w3centities-f;
]>
EOF

    feeds do |feed, filename|

      next if nothing_new? feed
      puts "fetching %s " % feed.rss_url.inspect
      
      rtd = RSStoDynarex.new feed.rss_url
      dynarex = rtd.to_dynarex

      dynarex.save(filename) do |xml| 
        a = xml.lines.to_a
        line1 = a.shift
        a.unshift %Q{<?xml-stylesheet title="XSL_formatting" type="text/xsl" href="dynarex-feed.xsl"?>\n}
        a.unshift w3centities
        a.unshift line1
        a.join
      end    

    end

  end

  def refresh

    feeds do |feed, filename|

      d = Dynarex.new filename

      feed.last_accessed = datetimestamp()
      feed.last_modified = datetimestamp() if feed.last_modified.empty?
      feed.xhtml = filename

      items = d.to_h[0..2]

      if feed.records.length > 0 and \
                              items.first[:title] == feed.item[0].title then
        feed.recent = recency(feed.last_modified)
        next 
      end

      puts 'adding : ' + filename.inspect

      feed.recent = 'a_hot'
      feed.records.remove_all
      items.each.with_index do |x, i|

        h = {
          title: x[:title],
          link:  x[:link],
          local_link: "%s#%s" % [filename.sub(/xml$/,'html'),i]
        }

        if i == 0 and feed.important != 'n' then

          raw_desc = CGI.unescapeHTML(x[:description]).gsub(/<\/?[^>]*>/, "")
          desc = raw_desc.length > 300 ? raw_desc[0..296] + ' ...' : raw_desc
          h[:description] = desc
        end

        feed.create.item h
      end

      feed.last_modified = datetimestamp()

    end
  end

  alias update_doc refresh

  def save_css(filepath='feeds.css')

    lib = File.dirname(__FILE__)
    css_buffer = File.read(lib + '/feeds.css')
    #css_buffer = File.read('feeds.css')

    File.write filepath, css_buffer
  end

  def save_html(filepath='feeds.html')
    xsltproc 'feeds.xsl', @polyrex.to_xml, filepath
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

  def feeds()

    @polyrex.records.each do |column|

      column.records.each do |section| 

        section.records.each do |feed|

          filename = "%s.xml" % feed.title.downcase.gsub(/\s/,'').gsub(/\W/,'_')

          begin
            yield(feed, filename)
          rescue
            puts ($!).inspect
          end

        end
      end
    end

  end
  
  def nothing_new?(feed)

    feed.occurrence == 'daily' and \
                                Time.parse(feed.last_accessed) + DAY > Time.now
  end

  def ordinal(i)
    i.to_s + ( (10...20).include?(i) ? 'th' : 
        %w{ th st nd rd th th th th th th }[i % 10] )
  end


  def recency(time)

    case (Time.now - Time.parse(time))
      when second(1)..minutes(5) then 'a_hot'
      when minutes(5)..hours(4) then 'b_warm'
      when hours(4)..week(1) then 'c_cold'
      when week(1)..month(1) then 'd_coldx1week'
      when month(1)..months(6) then 'e_coldx1month'
      else 'f_coldx6months'
    end
  end

  def xsltproc(xslfilename, xml, filepath='feeds.html')

    lib = File.dirname(__FILE__)
    xsl_buffer = File.read(lib + '/' + xslfilename)
    #xsl_buffer = File.read(xslfilename)

    xslt  = Nokogiri::XSLT(xsl_buffer)
    html = xslt.transform(Nokogiri::XML(xml)).to_s
    File.write filepath, html
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