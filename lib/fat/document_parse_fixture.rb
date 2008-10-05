# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'fat/string_writer'

module Fat

  class DocumentParseFixture < Fit::ColumnFixture
    attr_accessor :html
    attr_accessor :note # non-functional

    def output
      generate_output(Fit::Parse.new(@html))
    end

    def structure
      dump_tables(Fit::Parse.new(@html))
    end

    def dump_tables(table)
      result = ""
      separator = ""
      while (table) 
        result += separator
        result += dump_rows(table.parts)
        separator = "\n----\n"
        table = table.more
      end
      result
    end

    def dump_rows(row)
      result = ""
      separator = ""
      while (row)
        result += separator
        result += dump_cells(row.parts)
        separator = "\n"
        row = row.more
      end
      result
    end
	
    def dump_cells(cell)
      result = ""
      separator = ""
      while (cell) 
        result += separator
        result += "[" + cell.body + "]"
        separator = " "
        cell = cell.more
      end
      result
    end
    
    def generate_output parse
      result = StringWriter.new
      parse.print result
      result.to_s
    end
    
    private :dump_tables, :dump_rows, :dump_cells, :generate_output
    
  end
  
end
