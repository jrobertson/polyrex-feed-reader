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
<div id="wrap">
    <a name="top"/>

<header>
<a name="top"/>
    <xsl:apply-templates select='summary'/>    

  <div>
  <ul>
   <li>hotter</li>
   <li class="a_hot">&#160;</li>
   <li class="b_warm">&#160;</li>
   <li class="c_cold">&#160;</li>
   <li class="d_coldx1week">&#160;</li>
   <li class="e_coldx1month">&#160;</li>
   <li class="f_coldx6months">&#160;</li>
   <li>colder</li>
  </ul>
  </div>
</header>
   
    <nav>
    <a href="#top">return to top</a>
    <ul>     
    <xsl:for-each select="records/column/records/section/records/feed">
      <xsl:sort select="summary/title"/>
      <li class="{summary/recent}"><a href="#{summary/title}"><xsl:value-of select="summary/title"/></a></li>
    </xsl:for-each>
    </ul>
    </nav>
    <xsl:apply-templates select='records'/>
</div>    
    </body>
</html>
</xsl:template>



<xsl:template match='feeds/summary'>
  <a href="javascript:window.location.reload()"><h1><xsl:value-of select='title'/></h1></a>
</xsl:template>

<xsl:template match='records/column'>
<div id="{summary/id}">
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records/section'/>
</div>
</xsl:template>

<xsl:template match='column/summary'>

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
<div class="feed {summary/recent}">
    <a name="{summary/title}"/>
    <xsl:apply-templates select='summary'>

    </xsl:apply-templates>
    <ul><xsl:apply-templates select='records'/></ul>
</div>
</xsl:template>

<xsl:template match='feed/summary'>
  <a href="{substring-before(xhtml,'.')}.html" target="_blank" rel="nofollow"><h3><xsl:value-of select='title'/></h3></a>
  <span><xsl:value-of select='last_modified'/></span>
</xsl:template>

<xsl:template match='records/item'>
  <li>
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records'/>
  </li>
</xsl:template>

<xsl:template match='item/summary'>
  <a href="{local_link}" target="_blank" rel="nofollow"><h4><xsl:value-of disable-output-escaping="yes" select='title'/></h4></a>
  <p><xsl:value-of disable-output-escaping="yes" select='description'/></p>
</xsl:template>

</xsl:stylesheet>