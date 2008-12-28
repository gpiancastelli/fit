# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/column_fixture'

module Fit

  class ColumnFixtureTest < Test::Unit::TestCase

    # RubyForge bug #22283
    def test_camel
      fixture = TestColumnFixture.new
      header_text = "Execution Data Value"
      assert_equal "execution_data_value", fixture.camel(header_text)
    end

    class TestColumnFixture < ColumnFixture
      public :camel
    end

  end

end
