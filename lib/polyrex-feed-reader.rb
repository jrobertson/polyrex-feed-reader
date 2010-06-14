#!/usr/bin/ruby

# file: polyrex-feed-reader.rb

require 'polyrex'
require 'open-uri'
require 'rexml/document'
require 'builder'
require 'time'
require 'date'
require 'chronic'


class Fixnum
  def seconds() self end
  def minutes() self * 60 end
  def hours() self * 60 * 60 end
  def days() self * 3600 * 24 end
  def weeks() self * 3600 * 24 * 7 end
  def months() self * 86400 * 30 end
  alias second seconds; alias hour hours; alias minute minutes
  alias day days; alias week weeks; alias month months
end


class PolyrexFeedReader
  include REXML

  def initialize(file_path)
    @file_path = file_path
    if File.exists? @file_path then
      @feeds = Polyrex.new @file_path
    else
      schema = 'feeds/column[id]/feed[rss_url,title,important,occurrence,recent,url, xhtml, xhtml_mobile, last_modified]/item[title,link,description]'
      @feeds = Polyrex.new schema
      @feeds.save @file_path
    end
  end

  def parse(lines)
    @feeds.parse(lines)
  end

  def read()
    @feeds.records.each do |col|
      col.records.each do |feed|

        if scheduled? feed.occurrence and recency(feed.last_modified) != 'hot' then

          rss_doc = Document.new(open(feed.rss_url, 'UserAgent' => 'PolyrexFeedReader').read)
          rss_items = XPath.match(rss_doc.root, '//item')[0..2]

          if feed.records.length <= 0 then
            # create the items
            k = 3 - feed.records.length
            k.times {|x| feed.create.item}

            fetch_items(rss_items, feed)

          else
            if REXML::Text::unnormalize(feed.item[0].title) != rss_items[0].text('title').to_s then
              fetch_items(rss_items, feed)
            else
              feed.recent = recency(feed.last_modified)
            end
          end
        end
      end
      col.records.sort_by!{|x| -Time.parse(x.text('summary/last_modified').to_s).to_i}

    end

    @feeds.save @file_path

    a = @feeds.records.map {|column| column.records.select{|feed| feed.records.length > 0 }}
    interleaved = a[0].zip(*a[1..-1]).flatten

    xml = Builder::XmlMarkup.new( :target => buffer='', :indent => 2 )
    xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"

    xml.feeds do
      xml.summary do
        xml.recordx_type 'polyrex'
      end
      xml.records do
        interleaved.each do |feed|
          xml.feed do
            xml.summary do
              xml.title feed.title
              xml.last_modified feed.last_modified
              xml.recent feed.recent
              xml.important feed.important
            end
            xml.records do
              feed.records.each do |item|
                xml.item do            
                  xml.summary do
                    xml.title item.title
                    xml.description item.description
                  end
                  xml.records
                end
              end # 
            end # / records
          end # /feed
        end
      end # /records
    end

    buffer
  end

  private  

  def recency(time)  
    case (Time.now - Time.parse(time))
      when 1.second..5.minutes then 'hot'
      when 5.minutes..4.hours then 'warm'
      when 4.hours..1.week then 'cold'
      when 1.week..1.month then 'coldx1week'
      when 1.month..6.months then 'coldx1month'
      else 'coldx6months'
    end
  end

  def fetch_items(rss_items, feed)
    important = feed.important.downcase == 'important' 
    feed.last_modified = Time.now      
    feed.recent = 'hot'

    rss_items.each_with_index do |rss_item,i|
      feed.item[i].title = rss_item.text('title')        
    end
    feed.item[0].description = rss_items[0].text('description') if important
  end

  def scheduled?(s='')
    a = s.split(/,/).map &:strip
    return true if a.empty?

    d = Time.now.wday
    pattern = "%s|%s" % [Date::DAYNAMES[d],Date::ABBR_DAYNAMES[d]]
    a.map!{|x| x.sub(/#{pattern}/i,'today')}

    dates = a.map do |s|
      if s.split(/\s/).length > 1 then
        d = Chronic.parse(s, guess: false)
        [d.first, d.last]
      else
        d = Chronic.parse(s)
        d1 = d2 =  Time.parse("%s-%s-%s" % [d.year, d.month, d.day])
        [d1, d2 + 24.hours]
      end
    end

    dates.detect{|x| Time.now.between? *x} ? true : false
  end

end
