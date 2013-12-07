# Introducing the Polyrex-feed-reader

## Example

    require 'polyrex-feed-reader'

    # let's first of all identify the RSS feeds using a raw Polyrex document

    lines =<<LINES
    <?polyrex schema='feeds[title]/column[id]/feed[rss_url,title,important,occurrence,recent,url, xhtml, xhtml_mobile, last_modified, last_accessed]/item[title,link,description]'?>
    title: RSS feeds

    1
      http://feeds.wired.com/wired/index wired
      http://rss.slashdot.org/Slashdot/slashdot slashdot
    2
      http://feeds.bbci.co.uk/news/rss.xml?edition=uk BBC-News
      http://www.iftf.org/rss-feed/ iftf
      http://www.linux.com/feeds/all-content linux
    LINES


    px = Polyrex.new
    px.parse(lines)

    # we then pass the Polyrex document into the feed reader

    pfr = PolyrexFeedReader.new(px)
    pfr.fetch_feeds # fetch the RSS feeds and store them locally
    pfr.update_doc  # update the Polyrex document to include the feed items
    pfr.save_xml 'feeds.xml' # save the Polyrex document to file
    pfr.save_html 'feeds.html' # save the HTML file

This project is still under development however it's in working order. The next step will be to identify when a feed has been updated.

## Sample Output
![An HTML page containing the RSS feeds generated from Polyrex-feed-reader](http://www.jamesrobertson.eu/images/2013/dec/07/rss-feeds-screenshot.png)

## Resources

* [jrobertson/polyrex-feed-reader](https://github.com/jrobertson/polyrex-feed-reader)

polyrex feed rss reader gem
