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

W3CENTITIES =<<EOF
<!DOCTYPE stylesheet [
  <!ENTITY % w3centities-f PUBLIC "-//W3C//ENTITIES Combined Set//EN//XML"
      "http://www.w3.org/2003/entities/2007/w3centities-f.ent">
  %w3centities-f;
]>
EOF

class PolyrexFeedReader

  def initialize(polyrex)

    @polyrex = polyrex

  end  

  def feed_count()
    @polyrex.xpath 'count(records/column/records/section/records/feed)'
  end

  def feeds_to_html()

    feeds do |feed, filename|

      next if nothing_new? feed
      puts "transforming %s " % filename
      xsltproc 'dynarex-feed.xsl', File.read(filename), filename.sub(/xml$/,'html')
    end
  end

  def fetch_feeds()



    feeds do |feed, filename|

      next if nothing_new? feed
      puts "fetching %s " % feed.rss_url.inspect
      
      rtd = RSStoDynarex.new feed.rss_url
      dynarex = rtd.to_dynarex

      dynarex.save(filename) do |xml| 
        a = xml.lines.to_a
        line1 = a.shift
        a.unshift %Q{<?xml-stylesheet title="XSL_formatting" type="text/xsl" href="dynarex-feed.xsl"?>\n}
        a.unshift W3CENTITIES
        a.unshift line1
        a.join
      end    

    end

  end

  def refresh

    @datetimestamp = datetimestamp()

    feeds do |feed, filename|

      d = Dynarex.new filename

      feed.last_accessed = @datetimestamp
      feed.last_modified = @datetimestamp if feed.last_modified.empty?
      feed.xhtml = filename
      feed.url = d.summary[:link]

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

      feed.last_modified = @datetimestamp

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

  def save_latestnews(filename='latest.html')

    last_modified = @polyrex.summary.last_modified
    e = @polyrex.xpath 'records/column/records/section/records/'\
      + 'feed[summary/last_modified="' + last_modified + '"]'

    dynarex = Dynarex.new 'feeds/feed(source, title, link, description)'

    e.each() do |feed|

      summary = feed.element 'records/item/summary'

      record = {
             source: feed.text('summary/title'),
        source_link: feed.text('summary/url'),
              title: summary.text('title'),
               link: summary.text('link'),
        description: summary.text('description')
      }
      dynarex.create record
    end

    filename = 'latest.xml'
#=begin
    dynarex.save(filename) do |xml| 
      a = xml.lines.to_a
      line1 = a.shift
      a.unshift %Q{<?xml-stylesheet title="XSL_formatting" type="text/xsl" href="latest.xsl"?>\n}
      a.unshift W3CENTITIES
      a.unshift line1
      a.join
    end
#=end

    xsltproc 'latest.xsl', dynarex.to_xml, filename 
  end

  def save_opml(filepath='feeds.opml')
    xsltproc 'opml-feeds.xsl', @polyrex.to_xml, filepath
  end

  def save_sections()

    @polyrex.records.each do |column|

      column.records.each do |section|

        d = Dynarex.new 'section[title]/feed(source, title, link, description)'
        d.summary[:title] = section.title

        section.records.each.with_index do |feed, i|

          next if feed.item.length < 1
          filename = "%s.html#%s" % \
                            [feed.title.to_s.downcase.gsub(/\s/,'').gsub(/\W/,'_'), i]

          h = {source: feed.title, title: feed.item[0].title, link: filename, \
                  description: feed.item[0].description}
          d.create h
          puts h.inspect
        end

        filename = section.title.to_s.downcase.gsub(/\W/,'') + '.xml'
        d.save filename
      end
    end
end

  def save_xml(filepath='feeds.xml')
    @polyrex.summary.last_modified = @datetimestamp
    @polyrex.summary.feed_count = @polyrex.xpath \
                'count(records/column/records/section/records/feed)'
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

          filename = "%s.xml" % feed.title.to_s.downcase.gsub(/\s/,'').gsub(/\W/,'_')

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

    feed.last_accessed = Time.now - WEEK if feed.last_accessed.empty?
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
  pfr.save_latestnews 'latest.html'
  pfr.save_opml 'feeds.opml'
  pfr.save_sections
  #pfr.save_latestnews_css 'latest.css'

end