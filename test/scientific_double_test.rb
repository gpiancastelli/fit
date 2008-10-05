# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/scientific_double'

module Fit

  class ScientificDoubleTest < Test::Unit::TestCase
    def test_pi_number
      pi = 3.141592653
      assert_equal pi, ScientificDouble.value_of('3.14')
      assert_equal pi, ScientificDouble.value_of('3.142')
      assert_equal pi, ScientificDouble.value_of('3.1416')
      assert_equal pi, ScientificDouble.value_of('3.14159')
      assert_equal pi, ScientificDouble.value_of('3.141592653')

      assert_not_equal pi, ScientificDouble.value_of('3.140')
      assert_not_equal pi, ScientificDouble.value_of('3.144')
      assert_not_equal pi, ScientificDouble.value_of('3.1414')
      assert_not_equal pi, ScientificDouble.value_of('3.141492651')
    end
    def test_avogadro_number
      assert_equal 6.02e23, ScientificDouble.value_of('6.02e23')
      assert_equal 6.024E23, ScientificDouble.value_of('6.02E23')
      assert_equal 6.016e23, ScientificDouble.value_of('6.02e23')

      assert_not_equal 6.026e23, ScientificDouble.value_of('6.02e23')
      assert_not_equal 6.014e23, ScientificDouble.value_of('6.02e23')
    end
  end

end
