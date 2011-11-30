bibl2struct.xsl v. 08-03

* Transforms TEI <bibl>s into <biblstruct> bibliographies
* Author: (c) 2008 Ralf Stephan <ralf@ark.in-berlin.de>
* Published under GPL 2.0, see http://www.gnu.org/licenses/gpl-2.0.html

Description: the transform differentiates five major cases from
the (non)-existence of <title>s of certain @level (a,j,m,s). The
level in parens, e.g. (a) means 'level a or without/blank level'.

    - <bibl> has (a)+m+s titles ==> excerpt from work in series
    - <bibl> has   (m)+s titles ==> work in series
    - <bibl> has   (a)+j titles ==> journal article
    - <bibl> has   (a)+m titles ==> excerpt from monograph
    - <bibl> has     (m) titles ==> monograph

* When an element contains @corresp the text is taken from that id.
* When the document contains a <join result='bibl' />, we build that bibl and process it like the others.

TODO:
=====

  o  <title type='alt'> with <editor role='translator'>
  o  assume from existing <author /> that author of ref is author of work?
  o  handle <bibl>...<series>...</series>...</bibl>
  o  what do we do we with refs without title?
  o  what if we have <author><corr>...</corr></author> ?
