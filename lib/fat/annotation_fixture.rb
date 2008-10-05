# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fat/string_writer'
require 'fit/column_fixture'

module Fat

  class AnnotationFixture < Fit::ColumnFixture
  
    attr_accessor :original_html, :row, :column,
                  :overwrite_cell_body, :add_to_cell_body,
                  :overwrite_cell_tag, :overwrite_end_cell_tag, :add_to_cell_tag,
                  :overwrite_row_tag, :overwrite_end_row_tag, :add_to_row_tag,
                  :overwrite_table_tag, :overwrite_end_table_tag, :add_to_table_tag,
                  :add_cell_following, :remove_following_cell,
                  :add_row_following, :remove_following_row,
                  :add_table_following
                  
    def initialize
      super
      @row = @column = 0
    end

    def resulting_html
      table = Fit::Parse.new original_html
      row = table.at 0, @row - 1
      cell = row.at 0, @column - 1
      
      cell.body = @overwrite_cell_body unless @overwrite_cell_body.nil?
      cell.add_to_body(@add_to_cell_body) unless @add_to_cell_body.nil?
      
      cell.tag = @overwrite_cell_tag unless @overwrite_cell_tag.nil?
      cell.end = @overwrite_end_cell_tag unless @overwrite_end_cell_tag.nil?
      cell.add_to_tag(strip_delimiters(@add_to_cell_tag)) unless @add_to_cell_tag.nil?
      
      row.tag = @overwrite_row_tag unless @overwrite_row_tag.nil?
      row.end = @overwrite_end_row_tag unless @overwrite_end_row_tag.nil?
      row.add_to_tag(strip_delimiters(@add_to_row_tag)) unless @add_to_row_tag.nil?
      
      table.tag = @overwrite_table_tag unless @overwrite_table_tag.nil?
      table.end = @overwrite_end_table_tag unless @overwrite_end_table_tag.nil?
      table.add_to_tag(strip_delimiters(@add_to_table_tag)) unless @add_to_table_tag.nil?
      
      add_parse(cell, @add_cell_following, ['td']) unless @add_cell_following.nil?
      remove_parse(cell) unless @remove_following_cell.nil?
      
      add_parse(row, @add_row_following, ['tr', 'td']) unless @add_row_following.nil?
      remove_parse(row) unless @remove_following_row.nil?
      
      add_parse(table, @add_table_following, ['table', 'tr', 'td']) unless @add_table_following.nil?
      
      generate_output table
    end
    
    def add_parse parse, new_string, tags
      new_parse = Fit::Parse.new new_string, tags
      new_parse.more = parse.more
      new_parse.trailer = parse.trailer
      parse.more = new_parse
      parse.trailer = nil
    end
    
    def remove_parse parse
      parse.trailer = parse.more.trailer
      parse.more = parse.more.more
    end
    
    def strip_delimiters string
      string.gsub(/^\[/, '').gsub(/\]$/, '')
    end

    # Code smell note: copied from Fat::ParseFixture
    def generate_output parse
      result = StringWriter.new
      parse.print result
      result.to_s.strip
    end
    
    private :generate_output
  end

end
