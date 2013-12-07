<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" indent="yes" />

<xsl:template match='feeds'>
<xsl:element name="div">
    <xsl:apply-templates select='summary'/>    
    <xsl:apply-templates select='records'/>    
</xsl:element>
</xsl:template>

<xsl:template match='feeds/summary'>
  <h1><xsl:value-of select='title'/></h1>  
</xsl:template>

<xsl:template match='records/column'>

    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records'/>

</xsl:template>

<xsl:template match='column/summary'>
  <h2><xsl:value-of select='id'/></h2>
</xsl:template>

<xsl:template match='records/feed'>
    <xsl:apply-templates select='summary'/>
    <ul><xsl:apply-templates select='records'/></ul>
</xsl:template>

<xsl:template match='feed/summary'>
    <h3><xsl:value-of select='title'/></h3>
</xsl:template>

<xsl:template match='records/item'>
  <li>
    <xsl:apply-templates select='summary'/>
    <xsl:apply-templates select='records'/>
  </li>
</xsl:template>

<xsl:template match='item/summary'>
  <h4><xsl:value-of disable-output-escaping="yes" select='title'/></h4>
  <p><xsl:value-of disable-output-escaping="yes" select='description'/></p>
</xsl:template>

</xsl:stylesheet>
