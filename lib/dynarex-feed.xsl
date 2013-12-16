<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="yes" />
<xsl:template match="*">
  <html>
    <head>
    <!--<link rel='stylesheet' type='text/css' href='dynarex-feed.css' media='screen, projection, tv, print'></link>-->
    <style type="text/css">

      body {background-color: #aa5}
      #records {background-color: #888;}
      #records>ul {background-color: #ecf;list-style-type: none; margin: 0.2em; padding: 0.2em}
      #records>ul>li {   background-color: #956;}

      #records>ul>li:nth-child(even) { background:#4b3;  }
      #records>ul>li>div {
        background-color: #9ca;
        -moz-column-count: 3; -moz-column-gap: 1em; -moz-column-rule: 1px solid black; -webkit-column-count: 3; -webkit-column-gap: 1em; -webkit-column-rule: 1px solid black;
        margin:0.7em 0.3em; padding: 0.4em;

      }
      #records>ul>li:nth-child(even)>div { background-color: #ba8;  }
      #records>ul>li>div>a>h1 {background-color: transparent; font-size: 1.0em;}


    </style>
    </head>
  <body>
  <div id="wrap" class="dynarex">
      <ul>
        <li><a href="/">home</a></li>
        <li><a href="/feeds/">feeds</a></li>
      </ul>
  <xsl:apply-templates select="summary"/>
  <xsl:apply-templates select="records"/>
  </div>
  </body>
  </html>
</xsl:template>
<xsl:template match="summary">
<div id="summary">
<a href="{link}"><h1><xsl:value-of select="title" disable-output-escaping="yes"/></h1></a>
</div>
</xsl:template>

<xsl:template match="records">
<xsl:text>
</xsl:text><div id="records">

<xsl:text>
</xsl:text>
<ul><xsl:text>
</xsl:text>


<xsl:for-each select="item">

  <li><div><a name="{@id}"/>
    <a href="{link}" target="_blank"><h1><xsl:value-of select="title" disable-output-escaping="yes"/></h1></a>
    <p><xsl:value-of select="description" disable-output-escaping="yes"/></p>
    <p>last updated: <xsl:value-of select="date"/></p>
    <h2>Share</h2><textarea cols="50" rows="5">[<xsl:value-of select="title" disable-output-escaping="yes"/>](<xsl:value-of select="link" disable-output-escaping="yes"/>) via <xsl:value-of select="../../summary/title"/></textarea>
    </div>
  </li>

</xsl:for-each>

</ul><xsl:text>
</xsl:text>
</div>
</xsl:template>

</xsl:stylesheet>