# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'fit/scientific_double'

module Eg

  class ArithmeticColumnFixture < Fit::ColumnFixture
    attr_accessor :x, :y
    @@metadata = { 'sin()' => Fit::ScientificDouble, 'cos()' => Fit::ScientificDouble }
    def plus
      x + y
    end
    def minus
      x - y
    end
    def times
      x * y
    end
    def divide
      x / y
    end
    def floating
      Float(x) / Float(y)
    end
    def sin
      Fit::ScientificDouble.new Math.sin(x / 180.0 * Math::PI)
    end
    def cos
      Fit::ScientificDouble.new Math.cos(x / 180.0 * Math::PI)
    end
  end

end
