# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/file_runner'

module Fit
  
  class FileRunnerTest < Test::Unit::TestCase
    def test_simple_html
      simple_html = "<table>" +
                    "  <tr><td>fit.Fixture</td></tr>" +
                    "</table>"
      do_html simple_html
    end
    def test_wiki_html
      wiki_html = "<table><tr><td>extra formatting" +
                  "  <wiki>" +
                  "    <table>" +
                  "      <tr><td>fit.Fixture</td></tr>" +
                  "    </table>" +
                  "  </wiki>" +
                  "</td></tr></table>"
      do_html wiki_html
    end
    def do_html text
      runner = FileRunner.new
      runner.fixture = TempFixture.new
      runner.input = text
      runner.output = OutputStream.new
      runner.process

      assert_equal 'fit.Fixture', $tempParse.leaf.text
    end
  end

  # What's the Ruby  equivalent of Java anonymous classes?
  class TempFixture < Fixture
    def do_tables tables
      $tempParse = tables
    end
  end 

  # A dummy output stream
  class OutputStream < String
    def print text; end
    def close; end
  end

end
