<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="yes" />

<xsl:template match='feeds'>

    <html>
      <head>
        <title><xsl:value-of select="summary/title" /></title>
        <link rel="stylesheet" type="text/css" href="feeds.css" />
      </head>
      
      <body onload="" style="font-family:helvetica,arial;">

    <xsl:apply-templates select='summary'/>    
    <xsl:apply-templates select='records'/>    
    </body>
</html>
</xsl:template>



<xsl:template match='feeds/summary'>
  <h1><xsl:value-of select='title'/></h1>  
</xsl:template>

<xsl:template match='records/column'>
<div id="{summary/id}">
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records/section'/>
</div>
</xsl:template>

<xsl:template match='column/summary'>
  <h2><xsl:value-of select='id'/></h2>
</xsl:template>

<xsl:template match='records/section'>
<div>
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records/feed'>
       <xsl:sort select="summary/recent" order="ascending"/>
    </xsl:apply-templates>
</div>
</xsl:template>

<xsl:template match='section/summary'>
  <h2><xsl:value-of select='title'/></h2>
</xsl:template>


<xsl:template match='records/feed'>

    <xsl:apply-templates select='summary'>

    </xsl:apply-templates>
    <ul><xsl:apply-templates select='records'/></ul>
</xsl:template>

<xsl:template match='feed/summary'>
  <h3><xsl:value-of select='title'/></h3>
  <span><xsl:value-of select='last_modified'/></span>
</xsl:template>

<xsl:template match='records/item'>
  <li>
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records'/>
  </li>
</xsl:template>

<xsl:template match='item/summary'>
  <a href="{link}" target="_blank"><h4><xsl:value-of disable-output-escaping="yes" select='title'/></h4></a>
  <p><xsl:value-of disable-output-escaping="yes" select='description'/></p>
</xsl:template>

</xsl:stylesheet>