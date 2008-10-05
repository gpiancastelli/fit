# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fat

  class TableParseFixture < Fit::ColumnFixture
    attr_accessor :html, :row, :column
    def cell_body
      cell.body
    end
    def cell_tag
      cell.tag
    end
    def row_tag
      row.tag
    end
    def table_tag
      table.tag
    end
    def cell
      row.at 0, @column - 1
    end
    def row
      table.at 0, @row - 1
    end
    def table
      Fit::Parse.new(@html)
    end
  end

end