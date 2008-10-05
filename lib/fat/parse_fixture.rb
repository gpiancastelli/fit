# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fat/string_writer'
require 'fit/column_fixture'

module Fat

  # A fixture to discuss parsing specification.
  class ParseFixture < Fit::ColumnFixture

    attr_accessor :html, :table_cell, :entity
    attr_accessor :note # unused

    def generate_parse
      input_columns = 0
      html = nil
      unless @html.nil?
        input_columns += 1
        html = @html
      end
      unless @table_cell.nil?
        input_columns += 1
        html = "<table><tr>#@table_cell</tr></table>"
      end
      unless @entity.nil?
        input_columns += 1
        html = "<table><tr><td>#@entity</td></tr></table>"
      end

      raise "Exactly ONE of the following columns is needed: 'Html', 'TableCell', or 'Entity'" if input_columns != 1

      html.gsub!(/\\u00a0/, "\240")
      Fit::Parse.new html
    end

    def output; generate_output(generate_parse); end
    
    def generate_output parse
      result = StringWriter.new
      parse.print result
      result.to_s
    end

    def parse; dump_tables(generate_parse); end

    def dump_tables table
      result = ''
      separator = ''
      until table.nil?
        result += separator
        result += dump_rows(table.parts)
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
        result += dump_cells(row.parts)
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
        result += "[#{escape_ascii(cell.text)}]"
        separator = ' '
        cell = cell.more
      end
      result
    end
    
    def escape_ascii text
      text.gsub("\x0a", "\\n").gsub("\x0d", "\\r").gsub("\xa0", " ")
    end

    private :generate_parse, :generate_output
    private :dump_tables, :dump_rows, :dump_cells, :escape_ascii

  end

end
