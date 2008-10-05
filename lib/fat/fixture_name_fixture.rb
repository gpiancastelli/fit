# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fat

  class FixtureNameFixture < Fit::ColumnFixture
    attr_accessor :table
    def fixture_name
      table_parse = generate_table_parse(@table)
      dump_tables generate_table_parse(@table)
    end
    def dump_tables table
      result = ''
      separator = ''
      until table.nil?
        result += separator
        result += dump_rows table.parts
        separator = "\n----\n"
        table = table.more
      end
      result
    end
    def dump_rows row
      result = ''
      separator = ''
      until row.nil?
        result += separator
        result += dump_cells row.parts
        separator = "\n"
        row = row.more
      end
      result
    end
    def dump_cells cell
      result = ''
      separator = ''
      until cell.nil?
        result += separator
        result += "[#{cell.text}]"
        separator = ' '
        cell = cell.more
      end
      result
    end
    def valid_fixture; 'not implemented'; end
    def error; 'not implemented'; end
    def generate_table_parse table
      rows = table.split(/\n/)
      Fit::ParseHolder.create 'table', nil, generate_row_parses(rows, 0), nil
    end
    def generate_row_parses rows, row_index
      return nil if row_index >= rows.size
      md = /\[(.*?)\]/.match(rows[row_index])
      cells = md[1..-1]
      Fit::ParseHolder.create 'tr', nil, generate_cell_parses(cells, 0), generate_row_parses(rows, row_index + 1)
    end
    def generate_cell_parses cells, cell_index
      return nil if cell_index >= cells.size
      Fit::ParseHolder.create 'td', cells[cell_index], nil, generate_cell_parses(cells, cell_index + 1)
    end
    private :dump_tables, :dump_rows, :dump_cells
    private :generate_table_parse, :generate_row_parses, :generate_cell_parses
  end

end
