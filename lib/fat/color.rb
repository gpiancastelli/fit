# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/primitive_fixture'
require 'fat/table'

module Fat

  class Color < Fit::PrimitiveFixture
    def do_rows rows
      @actual_row = Table.table.parts
      raise "wrong size table" if not rows.size == @actual_row.size
      super
    end
    def do_row row
      super
      @actual_row = @actual_row.more
    end
    def do_cell cell, column_index
      check_value cell, color(@actual_row.parts.at(column_index))
    end
    def color cell
      b = extract cell.tag, 'bgcolor="', 'white'
      f = extract cell.body, '<font color="', 'black'
      f == 'black' ? b : "#{f}/#{b}"
    end
    def extract text, pattern, default_color
      index = text.index pattern
      return default_color if index.nil?
      index += pattern.size
      decode text[index..(index + 6)]
    end
    def decode code
      case code
        when Fit::Fixture::RED then 'red'
        when Fit::Fixture::GREEN then 'green'
        when Fit::Fixture::YELLOW then 'yellow'
        when Fit::Fixture::GRAY then 'gray'
        when '#808080' then 'gray'
        else code
      end
    end
  end

end
