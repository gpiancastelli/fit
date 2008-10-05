# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/fixture'
require 'fit/parse'

module Fit

  class FrameworkTest < Test::Unit::TestCase
    def test_runs
      # The original Java version for the arithmetic fixture led to
      # 37, 10, 0, 2 as results, but Ruby handles maths differently.
      # Using a more strict delta in Fit::TypeAdapter could lead to
      # worse results on the Ruby front.
      run_page 'arithmetic', 39, 8, 0, 2
      run_page 'BinaryChop', 95, 0, 0, 0
      run_page 'CalculatorExample', 75, 9, 0, 0
      run_page 'MusicExample', 95, 0, 0, 0
      run_page 'MusicExampleWithErrors', 54, 10, 0, 0
      run_page 'NetworkExample', 5, 0, 0, 0
      # run_page 'SimpleExample', 5, 0, 0, 0
    end
    def run_page file, right, wrong, ignores, exceptions
      input = File.open("../../examples/#{file}.html") {|f| f.read}
      fixture = Fixture.new
      tables = nil
      unless input.index('<wiki>').nil?
        tables = Parse.new input, ['wiki', 'table', 'tr', 'td']
        fixture.do_tables tables.parts
      else
        tables = Parse.new input, ['table', 'tr', 'td']
        fixture.do_tables tables
      end
      tables.print OutputStream.new
      
      assert_equal right, fixture.counts.right, "#{file} right"
      assert_equal wrong, fixture.counts.wrong, "#{file} wrong"
      assert_equal ignores, fixture.counts.ignores, "#{file} ignores"
      assert_equal exceptions, fixture.counts.exceptions, "#{file} exceptions"
    end
  end

  # A dummy output stream to avoid creating output files
  class OutputStream < String
    def print text; end
  end

end
