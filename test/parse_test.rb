# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/parse'

module Fit

  class ParseTest < Test::Unit::TestCase
    def test_parsing
      p = Parse.new 'leader<Table foo=2>body</table>trailer', ['table']
      assert_equal 'leader', p.leader
      assert_equal '<Table foo=2>', p.tag
      assert_equal 'body', p.body
      assert_equal 'trailer', p.trailer
    end
    def test_recursing
      p = Parse.new 'leader<table><TR><Td>body</tD></TR></table>trailer'
      assert_nil p.body
      assert_nil p.parts.body
      assert_equal 'body', p.parts.parts.body
    end
    def test_iterating
      p = Parse.new 'leader<table><tr><td>one</td><td>two</td><td>three</td></tr></table>trailer'
      assert_equal 'one', p.parts.parts.body
      assert_equal 'two', p.parts.parts.more.body
      assert_equal 'three', p.parts.parts.more.more.body
    end
    def test_indexing
      p = Parse.new 'leader<table><tr><td>one</td><td>two</td><td>three</td></tr><tr><td>four</td></tr></table>trailer'
      assert_equal 'one', p.at(0, 0, 0).body
      assert_equal 'two', p.at(0,0,1).body
      assert_equal 'three', p.at(0,0,2).body
      assert_equal 'three', p.at(0,0,3).body
      assert_equal 'three', p.at(0,0,4).body
      assert_equal 'four', p.at(0,1,0).body
      assert_equal 'four', p.at(0,1,1).body
      assert_equal 'four', p.at(0,2,0).body
      assert_equal 1, p.size()
      assert_equal 2, p.parts.size()
      assert_equal 3, p.parts.parts.size()
      assert_equal 'one', p.leaf().body
      assert_equal 'four', p.parts.last().leaf().body
    end
    def test_parse_exception
      begin
        p = Parse.new 'leader<table><tr><th>one</th><th>two</th><th>three</th></tr><tr><td>four</td></tr></table>trailer'
        fail 'Expected ParseException not thrown.'
      rescue ParseException => e
        assert_equal 17, e.error_offset
        assert_equal "Can't find tag: td", e.message
      end
    end
    def test_text
      tags = ['td']
      p = Parse.new '<td>a&lt;b</td>', tags
      assert_equal 'a&lt;b', p.body
      assert_equal 'a<b', p.text
      p = Parse.new "<td>\ta&gt;b&nbsp;&amp;&nbsp;b>c &&&lt;</td>", tags
      assert_equal 'a>b & b>c &&<', p.text
      p = Parse.new "<td>\ta&gt;b&nbsp;&amp;&nbsp;b>c &&lt;</td>", tags
      assert_equal 'a>b & b>c &<', p.text
      p = Parse.new '<TD><P><FONT FACE="Arial" SIZE=2>GroupTestFixture</FONT></TD>', tags
      assert_equal 'GroupTestFixture', p.text()
    end
    def test_html_to_text
      assert_equal '', Parse.html_to_text('&nbsp;')
      assert_equal 'a b', Parse.html_to_text('a <tag /> b')
      assert_equal 'a', Parse.html_to_text('a &nbsp;')
      assert_equal '&nbsp;', Parse.html_to_text('&amp;nbsp;')
      assert_equal '1     2', Parse.html_to_text('1 &nbsp; &nbsp; 2')
      assert_equal '1     2', Parse.html_to_text("1 \xa0\xa0\xa0\xa02")
      assert_equal 'a', Parse.html_to_text('  <tag />a')
      assert_equal "a\nb", Parse.html_to_text('a<br />b')
      assert_equal 'ab', Parse.html_to_text('<font size=+1>a</font>b')
      assert_equal 'ab', Parse.html_to_text('a<font size=+1>b</font>')
      assert_equal 'a<b', Parse.html_to_text('a<b')
      assert_equal "a\nb\nc\nd", Parse.html_to_text('a<br>b<br/>c<  br   /   >d')
      assert_equal "a\nb", Parse.html_to_text('a</p><p>b')
      assert_equal "a\nb", Parse.html_to_text('a< / p >   <   p  >b')
    end
    def test_unescape
      assert_equal 'a<b', Parse.unescape('a&lt;b')
      assert_equal 'a>b & b>c &&', Parse.unescape('a&gt;b&nbsp;&amp;&nbsp;b>c &&')
      assert_equal '&amp;&amp;', Parse.unescape('&amp;amp;&amp;amp;')
      assert_equal 'a>b & b>c &&', Parse.unescape('a&gt;b&nbsp;&amp;&nbsp;b>c &&')
      assert_equal "'\"\"'", Parse.unescape("\221“”\222")
    end
    def test_whitespace_is_condensed
      assert_equal 'a b', Parse.condense_whitespace(' a  b  ')
      assert_equal 'a b', Parse.condense_whitespace(" a  \n\tb  ")
      assert_equal '', Parse.condense_whitespace(' ')
      assert_equal '', Parse.condense_whitespace('  ')
      assert_equal '', Parse.condense_whitespace('   ')
      assert_equal '', Parse.condense_whitespace("\240")
    end
  end

end
