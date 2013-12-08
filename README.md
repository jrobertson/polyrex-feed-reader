# Polyrex-feed-reader: columns, sections, and feeds

Polyrex-feed-reader version 0.5.3 now includes sections to allow feeds to be grouped by subject within a column.

## Example

I recommend running the example below from an *irb* session within its own directory (e.g. `~/feeds/`) for saving the temporary feeds as well as the feeds.html file.

    require 'polyrex-feed-reader'

    lines =<<LINES
    <?polyrex schema='feeds[title]/column[id, title]/section[title]/feed[rss_url,title,important,occurrence,recent,url, xhtml, xhtml_mobile, last_modified, last_accessed]/item[title,link,description]' delimiter=' # '?>
    title: RSS feeds

    c1
      Hands-on
        http://www.reddit.com/r/raspberry_pi/.rss # Reddit #raspberrypi
    c2
      News
        http://feeds.bbci.co.uk/news/rss.xml?edition=uk # BBC News
      Technology
        http://feeds.wired.com/wired/index # Wired
        http://rss.slashdot.org/Slashdot/slashdot # Slashdot
        http://www.linux.com/feeds/all-content # Linux.com
    c3
      Programming
        http://www.reddit.com/r/ruby/.rss # Reddit #ruby
      Innovation
        http://www.iftf.org/rss-feed/ # iftf
    LINES



    px = Polyrex.new
    px.parse(lines)

    pfr = PolyrexFeedReader.new(px)
    pfr.fetch_feeds
    pfr.update_doc
    pfr.save_xml 'feeds.xml'
    pfr.save_html 'feeds.html'
    pfr.save_css 'feeds.css'

Here's a sample of what to expect:

![RSS feeds web page screenshot](http://www.jamesrobertson.eu/images/2013/dec/08/rss-feeds-screenshot.png)

## Resources

* [jrobertson/polyrex-feed-reader](https://github.com/jrobertson/polyrex-feed-reader)

gem polyrexfeedreader rss polyrex
