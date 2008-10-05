# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/row_fixture'

module Fit

  class RowFixtureTest < Test::Unit::TestCase

    def test_match
      fixture = TestRowFixture.new
      adapter = TypeAdapter.for(fixture, 'get_strings', false)
      fixture.column_bindings = [adapter]
      computed = [BusinessObject.new(["1"])]
      expected = [ParseHolder.create('tr', '', ParseHolder.create('td', '1', nil, nil), nil)]
      fixture.match expected, computed, 0

      puts fixture.counts.to_s # 0, 0, 0, 0 (!!!)
      puts fixture.missing.size # 1
      puts fixture.surplus.size # 1
      assert_equal 1, fixture.counts.right, 'right'
      assert_equal 0, fixture.counts.exceptions, 'exceptions'
      assert_equal 0, fixture.missing.size, 'missing'
      assert_equal 0, fixture.surplus.size, 'surplus'
    end

    class BusinessObject
      def initialize strings
        @strings = strings
      end
      def get_strings
        @strings
      end
    end

    class TestRowFixture < RowFixture
    end

  end

end
