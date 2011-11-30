bibl2struct.xsl v. 08-03

* Transforms TEI <bibl>s into <biblstruct> bibliographies
* Author: (c) 2008 Ralf Stephan <ralf@ark.in-berlin.de>
* Published under GPL 2.0, see http://www.gnu.org/licenses/gpl-2.0.html

Description: the transform differentiates five major cases from
the (non)-existence of &lt;title&gt;s of certain level (a,j,m,s). The
level in parens, e.g. (a) means 'level a or without/blank level'.

    - <bibl> has (a)+m+s titles ==> excerpt from work in series
    - <bibl> has   (m)+s titles ==> work in series
    - <bibl> has   (a)+j titles ==> journal article
    - <bibl> has   (a)+m titles ==> excerpt from monograph
    - <bibl> has     (m) titles ==> monograph

* When an element contains corresp the text is taken from that id.
* When the document contains a &lt;join result='bibl' /&gt;, we build that bibl and process it like the others.

TODO:
=====

* &lt;title type='alt'&gt; with &lt;editor role='translator'&gt;
* assume from existing &lt;author /&gt; that author of ref is author of work?
* handle &lt;bibl&gt; &hellip; &lt;series &gt; &hellip; &lt;/series &gt; hellip; &lt;/bibl&gt;
* what do we do we with refs without title?
* what if we have &lt;author&gt;&lt;corr&gt; &hellip; &gt;/corr&gt;&lt;/author&gt; ?
