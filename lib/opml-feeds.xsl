<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" encoding="UTF-8" />

<xsl:template match='feeds'>
<opml version="1.0">
<head><xsl:apply-templates select='summary'/></head>      
<body>   
  <xsl:apply-templates select='records'/>
</body>
</opml>
</xsl:template>

<xsl:template match='feeds/summary'>
  <title><xsl:value-of select="title" /></title>
</xsl:template>

<xsl:template match='records/column'>
  <xsl:apply-templates select='summary'/>
  <xsl:apply-templates select='records/section'/>
</xsl:template>

<xsl:template match='column/summary'/>

<xsl:template match='records/section'>
  <outline title="{summary/title}" text="{summary/title}" description="" type="folder">
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records/feed'/>
  </outline>
</xsl:template>

<xsl:template match='section/summary'/>

<xsl:template match='records/feed'>
  <xsl:apply-templates select='summary'/>
  <xsl:apply-templates select='records'/>
</xsl:template>

<xsl:template match='feed/summary'>
  <outline title="{title}" text="{title}" description="{title}" type="rss" xmlUrl="{rss_url}" htmlUrl=""/>
</xsl:template>

<xsl:template match='records/item'>
  <xsl:apply-templates select='summary'/>
  <xsl:apply-templates select='records'/>
</xsl:template>

<xsl:template match='item/summary'/>
<xsl:template match='item/records'/>

</xsl:stylesheet>
