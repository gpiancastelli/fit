# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'

module Fit

  class PrimitiveFixture < Fixture

    # Format converters

    def parse_integer cell
      Integer cell.text
    end

    def parse_double cell
      Float cell.text
    end

    def parse_boolean cell
      cell.text.downcase == 'true' ? true : false
    end

    # Answer comparison

    def check_value cell, value
      if value.to_s == cell.text
        right cell
      else
        wrong cell, value.to_s
      end
    end

    def check_boolean cell, value
      if value == parse_boolean(cell)
        right cell
      else
        wrong cell, value.to_s
      end
    end

    def check cell, expected, value
      if expected == value
        right cell
      else
        wrong cell, value
      end
    end

  end

end
