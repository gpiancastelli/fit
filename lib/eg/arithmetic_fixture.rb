# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/primitive_fixture'

module Eg

  class ArithmeticFixture < Fit::PrimitiveFixture
    def initialize
      super
      @x = @y = 0
    end
    def do_rows rows
      super(rows.more) # skip column heads
    end
    def do_cell cell, column_index
      case column_index
        when 0 then @x = parse_integer(cell);
        when 1 then @y = parse_integer(cell);
        when 2 then check(cell, parse_integer(cell), @x + @y)
        when 3 then check(cell, parse_integer(cell), @x - @y)
        when 4 then check(cell, parse_integer(cell), @x * @y)
        when 5 then check(cell, parse_integer(cell), @x / @y)
        else ignore(cell)
      end
    end
  end

end
