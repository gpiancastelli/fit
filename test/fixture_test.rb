# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/fixture'
require 'fit/parse'

module Fit

  class FixtureTest < Test::Unit::TestCase
    def test_escape
      junk = "!@$%^*()_-+={}|[]\\:\";',./?`#"
      assert_equal junk, Fixture.escape(junk)

      assert_equal ' &nbsp; &nbsp; ', Fixture.escape('     ')
      assert_equal '', Fixture.escape('')
      assert_equal '&lt;', Fixture.escape('<')
      assert_equal '&lt;&lt;', Fixture.escape('<<')
      assert_equal 'x&lt;', Fixture.escape('x<')
      assert_equal '&amp;', Fixture.escape('&')
      assert_equal '&lt;&amp;&lt;', Fixture.escape('<&<')
      assert_equal '&amp;&lt;&amp;', Fixture.escape('&<&')
      assert_equal 'a &lt; b &amp;&amp; c &lt; d', Fixture.escape('a < b && c < d')
      assert_equal 'a<br />b', Fixture.escape("a\nb")
    end
    class ArgsFixture < Fit::Fixture
      @@args = nil
      def do_table table
        @@args = @args
      end
      def self.args; @@args; end
    end
    def test_it_passes_parameters
      p = Parse.new '<table><tr><td>Fit.FixtureTest.ArgsFixture</td><td>a</td><td>b</td></tr></table>' 
      Fixture.new.do_tables p      
      assert_equal ['a', 'b'], ArgsFixture.args
    end
  end
end
