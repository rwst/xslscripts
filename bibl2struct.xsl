<?xml version="1.0"?>
<!-- bibl2struct.xsl v. 08-03
  Transforms TEI <bibl>s into <biblstruct> bibliographies
  Author: (c) 2008 Ralf Stephan <ralf@ark.in-berlin.de>
  Published under GPL 2.0, see http://www.gnu.org/licenses/gpl-2.0.html

  Description: the transform differentiates five major cases from
  the (non)-existence of <title>s of certain @level (a,j,m,s). The
    level in parens, e.g. (a) means 'level a or without/blank level'.
    - <bibl> has (a)+m+s titles ==> excerpt from work in series
    - <bibl> has   (m)+s titles ==> work in series
    - <bibl> has   (a)+j titles ==> journal article
    - <bibl> has   (a)+m titles ==> excerpt from monograph
    - <bibl> has     (m) titles ==> monograph

  When an element contains @corresp the text is taken from that id.
  When the document contains a <join result='bibl' />, we build that bibl
    and process it like the others.

    History/Changelog:
    o 08-03: 
      - removed <link> functionality
      - fixed <join> and @corresp matching priorities
      - @corresp didn't work at all
      - <edition> wasn't printed
      - journal refs without title weren't handled
      - no editor in simple monographs
      - better matching for elements that can occur outside <bibl>
      - added <corr> and <name> handling
    o 08-01: published
  TODO:
  =====
  o  <title type='alt'> with <editor role='translator'>
  o  assume from existing <author /> that author of ref is author of work?
  o  handle <bibl>...<series>...</series>...</bibl>
  o  what do we do we with refs without title?
  o  what if we have <author><corr>...</corr></author> ?
  -->
  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

    <xsl:output method="xml" encoding="UTF-8"
	    doctype-public="-//TEI P5//DTD Main Document Type//EN" 
	    doctype-system="tei2.dtd" />

    <!-- Include a link to CSS -->
    <xsl:template match="/">
      <xsl:processing-instruction name="xml-stylesheet">href="eb-bib.css" type="text/css"</xsl:processing-instruction>
      <listBibl>
        <xsl:apply-templates />
      </listBibl>
    </xsl:template>

    <!-- remove all default attributes -->
    <xsl:template match="@status"></xsl:template>
    <xsl:template match="@default"></xsl:template>
    <xsl:template match="@org[.='uniform']"></xsl:template>
    <xsl:template match="@sample[.='complete']"></xsl:template>
    <xsl:template match="@part[.='N']"></xsl:template>
    <xsl:template match="@direct[.='unspecified']"></xsl:template>
    <xsl:template match="@targOrder[.='U']"></xsl:template>
    <xsl:template match="@from[.='ROOT']"></xsl:template>
    <xsl:template match="@anchored[.='yes']"></xsl:template>
    <xsl:template match="@place[.='unspecified']"></xsl:template>
    <xsl:template match="teiHeader/@type"></xsl:template>

    <!-- do not copy all CDATA, we copy explicitly later -->
    <xsl:template match="text()" />

    <!-- ignore teiHeader -->
    <xsl:template match='teiHeader' />

    <!-- <bibl> without <title> does nothing -->
    <xsl:template match='bibl[not(title)]' />

    <!-- handle <join result='bibl'> here -->
    <xsl:template match='join[@result="bibl"]' priority='1'>
      <xsl:variable name='joint'>
        <bibl>
        <xsl:call-template name='chomp-targets-recursively'>
          <xsl:with-param name='idstr'>
            <xsl:value-of select='@targets' />
          </xsl:with-param>
        </xsl:call-template>
        </bibl>
      </xsl:variable>
      <xsl:apply-templates select='exsl:node-set($joint)//bibl' />
    </xsl:template>

    <!-- Calls copy-of with all ids in targets string -->
    <!-- Partly stolen from http://wwbota.free.fr/XSLT_models/split-string.xslt-->
    <xsl:template name='chomp-targets-recursively'>
      <xsl:param name='idstr' />
      <xsl:variable name="first">
        <xsl:variable name="first0" select="substring-before($idstr,' ')"/>
        <xsl:choose>
          <xsl:when test="$first0">
            <xsl:copy-of select="$first0"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$idstr"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="string-length($first)">
        <xsl:call-template name='chomp-targets-recursively'>
          <xsl:with-param name="idstr">
            <xsl:value-of select="substring-after($idstr,' ')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:copy-of select='//*[@id=$first]' />
      </xsl:if>
    </xsl:template>

    <!-- Handle bibl with elements having @corresp attribute -->
    <xsl:template match='bibl[*[@corresp]]' priority='1'>
      <xsl:variable name='tmp1'>
        <bibl>
          <xsl:apply-templates select='*' /> <!--corresp is handled -->
        </bibl>                              <!--at element level   -->
      </xsl:variable>
      <xsl:apply-templates select='exsl:node-set($tmp1)//bibl' />
    </xsl:template>

    <!--===================================-->
    <!-- complete bibl with titles (a)+m+s -->
    <xsl:template match='bibl[(title[@level="a"] or title[@level=""] or title[not(@level)]) and title[@level="m"] and title[@level="s"]]'>
      <biblStruct>
        <analytic>
          <xsl:apply-templates select='author' />
          <xsl:apply-templates select='title[(@level="a" or @level="" or not(@level))]' />
        </analytic>
        <monogr>
          <xsl:apply-templates select='editor' />
          <xsl:apply-templates select='title[@level="m"]' />
        </monogr>
        <series>
          <xsl:apply-templates select='editor' />
          <xsl:apply-templates select='title[@level="s"]' />
          <xsl:if test='date|edition|publisher|pubPlace|biblScope'>
          <imprint>
            <xsl:apply-templates select='publisher' />
            <xsl:apply-templates select='pubPlace' />
            <xsl:apply-templates select='edition' />
            <xsl:apply-templates select='date' />
            <xsl:apply-templates select='biblScope' />
          </imprint>
        </xsl:if>
        </series>
        <xsl:apply-templates select='note' />
      </biblStruct>
    </xsl:template>

    <!-- complete bibl with titles (m)+s -->
    <xsl:template match='bibl[not(title[@level="a"]) and (title[@level="m"] or title[@level=""] or title[not(@level)]) and title[@level="s"]]'>
      <biblStruct>
        <monogr>
          <xsl:apply-templates select='author' />
          <xsl:apply-templates select='title[@level="m" or @level="" or not(@level)]' />
          <xsl:if test='date|edition|publisher|pubPlace|biblScope'>
          <imprint>
            <xsl:apply-templates select='publisher' />
            <xsl:apply-templates select='pubPlace' />
            <xsl:apply-templates select='edition' />
            <xsl:apply-templates select='date' />
            <xsl:apply-templates select='biblScope' />
          </imprint>
        </xsl:if>
        </monogr>
        <series>
          <xsl:apply-templates select='editor' />
          <xsl:apply-templates select='title[@level="s"]' />
        </series>
        <xsl:apply-templates select='note' />
      </biblStruct>
    </xsl:template>

    <!-- bibl with title (a)+j -->
    <xsl:template match='bibl[not(title[@level="m"]) and not(title[@level="s"]) and title[@level="j"]]'>
      <biblStruct>
        <analytic>
          <xsl:apply-templates select='author' />
          <xsl:apply-templates select='title[not(@level) or @level="a"]' />
        </analytic>
        <monogr>
          <xsl:apply-templates select='title[@level="j"]' />
          <xsl:if test='date|publisher|pubPlace|biblScope'>
          <imprint>
            <xsl:apply-templates select='publisher' />
            <xsl:apply-templates select='pubPlace' />
            <xsl:apply-templates select='date' />
            <xsl:apply-templates select='biblScope' />
          </imprint>
        </xsl:if>
        <xsl:apply-templates select='editor' />
        </monogr>
        <xsl:apply-templates select='note' />
      </biblStruct>
    </xsl:template>

    <!-- complete bibl with title (a)+m -->
    <xsl:template match='bibl[title[not(@level) or @level="a"] and title[@level="m"]]'>
      <biblStruct>
        <analytic>
          <xsl:apply-templates select='author' />
          <xsl:apply-templates select='title[not(@level) or @level="a"]' />
        </analytic>
        <monogr>
          <xsl:apply-templates select='editor' />
          <xsl:apply-templates select='title[@level="m"]' />
          <xsl:if test='date|edition|publisher|pubPlace|biblScope'>
          <imprint>
            <xsl:apply-templates select='publisher' />
            <xsl:apply-templates select='pubPlace' />
            <xsl:apply-templates select='edition' />
            <xsl:apply-templates select='date' />
            <xsl:apply-templates select='biblScope' />
          </imprint>
        </xsl:if>
        </monogr>
        <xsl:apply-templates select='note' />
      </biblStruct>
    </xsl:template>

    <!-- bibl with either title m only or blank only, all without a,j,s -->
    <xsl:template match='bibl[(not(title[@level="a"]) and not(title[@level="j"]) and not(title[@level="s"])) and ((title[@level="m"] and not(title[not(@level)])) or (not(title[@level="m"]) and title[not(@level)]))]'>
      <biblStruct>
        <monogr>
          <xsl:apply-templates select='author' />
          <xsl:apply-templates select='title' />
          <xsl:apply-templates select='editor' />
          <xsl:if test='date|edition|publisher|pubPlace|biblScope'>
          <imprint>
            <xsl:apply-templates select='publisher' />
            <xsl:apply-templates select='pubPlace' />
            <xsl:apply-templates select='edition' />
            <xsl:apply-templates select='date' />
            <xsl:apply-templates select='biblScope' />
          </imprint>
        </xsl:if>
        </monogr>
        <xsl:apply-templates select='note' />
      </biblStruct>
    </xsl:template>

    <!--=========================================-->
    <!-- all elements except (title outside of bibl): do deep copy -->
    <xsl:template match="@* | author | title [ancestor::bibl] | editor | 
      biblScope | edition | date[ancestor::bibl] | publisher | pubPlace | 
      note[ancestor::bibl] | corr | name[ancestor::bibl]">
      <xsl:choose>
        <xsl:when test='@corresp'>
          <xsl:variable name='tmp'>
            <bibl> 
              <xsl:copy>
                <xsl:copy-of select='id(@corresp)/@*' />
                <xsl:copy-of select='id(@corresp)/node()' />
              </xsl:copy>
            </bibl>
          </xsl:variable>
          <xsl:apply-templates select='exsl:node-set($tmp)//bibl/*' />
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy>
            <xsl:apply-templates select="@*[not(name()='TEIform')]|node()|text()"/>
          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match='bibl/series'>
      <xsl:text>seriesabc</xsl:text>
      <xsl:copy-of select='*/node()' />
    </xsl:template>

    <!-- copy CDATA within elements except titles -->
    <xsl:template match="bibl/text() | author/text() | editor/text() | 
      //bibl//title/text() | biblScope/text() | //bibl//date/text() | 
      edition/text() | pubPlace/text() | publisher/text() | //bibl//note/text() 
      | //bibl//corr/text() | //bibl//name/text()">
      <xsl:copy />
    </xsl:template>

</xsl:stylesheet>

