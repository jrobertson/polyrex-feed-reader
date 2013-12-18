<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="yes" />
<xsl:template match="*">
  <html>
    <head>
    <link rel='stylesheet' type='text/css' href='dynarex-feed.css' media='screen, projection, tv, print'></link>

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

<ul>
<xsl:for-each select="feed">

  <li><xsl:value-of select="source" disable-output-escaping="yes"/>: <a href="#{position()}"><xsl:value-of select="title" disable-output-escaping="yes"/></a></li>

</xsl:for-each>
</ul>
<xsl:text>
</xsl:text>
<ul><xsl:text>
</xsl:text>


<xsl:for-each select="feed">

  <li><div><a name="{@id}"/>
    <h2><xsl:value-of select="source" disable-output-escaping="yes"/></h2>
    <a href="{link}" target="_blank" rel="nofollow"><h1><xsl:value-of select="title" disable-output-escaping="yes"/></h1></a>
    <p><xsl:value-of select="description" disable-output-escaping="yes"/></p>
    <h3>Share</h3><textarea cols="50" rows="5">[<xsl:value-of select="title" disable-output-escaping="yes"/>](<xsl:value-of select="link" disable-output-escaping="yes"/>) via <xsl:value-of select="../../summary/title"/></textarea>
    </div>
  </li>

</xsl:for-each>

</ul><xsl:text>
</xsl:text>
</div>
</xsl:template>

</xsl:stylesheet>
