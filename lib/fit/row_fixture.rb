# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'fit/parse'
require 'fit/type_adapter'

module Fit

  class RowFixture < ColumnFixture

    attr_accessor :results
    attr_accessor :missing, :surplus

    def initialize
      super
      @missing = []
      @surplus = []
    end

    def do_rows rows
      begin
        bind rows.parts
        @results = query
        match list(rows.more), @results, 0
        last = rows.last
        last.more = build_rows @surplus
        mark_parse last.more, 'surplus'
        mark_list @missing, 'missing'
      rescue Exception => e
        exception rows.leaf, e
      end
    end

    # Gets rows to be compared
    def query; end

    protected

    def match expected, computed, column_index
      if column_index >= @column_bindings.size
        check_list expected, computed
      elsif @column_bindings[column_index].nil?
        match(expected, computed, column_index + 1)
      else
        e_map = e_sort(expected, column_index)
        c_map = c_sort(computed, column_index)
        keys = e_map.keys | c_map.keys
        keys.each do |key|
          e_list = e_map[key]
          c_list = c_map[key]
          if e_list.nil?
            @surplus += c_list
          elsif c_list.nil?
            @missing += e_list
          elsif e_list.size == 1 and c_list.size == 1
            check_list e_list, c_list
          else
            match(e_list, c_list, column_index + 1)
          end
        end
      end
    end

    def list rows
      result = []
      until rows.nil?
        result << rows
        rows = rows.more
      end
      result
    end

    def e_sort list, column_index
      adapter = @column_bindings[column_index]
      result = {}
      list.each do |row|
        cell = row.parts.at(column_index)
        begin
          key = adapter.parse(cell.text)
          bin(result, key, row)
        rescue Exception => e
          exception cell, e
          rest = cell.more
          until rest.nil?
            ignore rest
            rest = rest.more
          end
        end
      end
      result
    end

    def c_sort list, column_index
      adapter = @column_bindings[column_index]
      result = {}
      list.each do |row|
        begin
          adapter.target = row
          key = adapter.get
          bin(result, key, row)
        rescue Exception => e
          @surplus << row # surplus anything with bad keys, including nil
        end
      end
      result
    end

    def bin map, key, row
      if map.include? key
        map[key] <<= row
      else
        map[key] = [row]
      end
    end

    def check_list e_list, c_list
      if e_list.empty?
        @surplus += c_list
        return
      end
      if c_list.empty?
        @missing += e_list
        return
      end
      row = e_list.shift
      cell = row.parts
      obj = c_list.shift
      @column_bindings.each do |adapter|
        adapter.target = obj unless adapter.nil?
        check cell, adapter
        cell = cell.more
        break if cell.nil?
      end
      check_list e_list, c_list
    end

    def mark_parse rows, message
      annotation = Fixture.label message
      until rows.nil?
        wrong rows.parts
        rows.parts.add_to_body annotation
        rows = rows.more
      end
    end

    def mark_list rows, message
      annotation = Fixture.label message
      rows.each do |row|
        wrong row.parts
        row.parts.add_to_body annotation
      end
    end

    def build_rows rows
      root_parse = ParseHolder.create nil, nil, nil, nil
      next_parse = root_parse
      rows.each {|row| next_parse = next_parse.more = ParseHolder.create('tr', nil, build_cells(row), nil)}
      root_parse.more
    end

    def build_cells row
      if row.nil?
        nihil = ParseHolder.create 'td', 'nil', nil, nil
        nihil.add_to_tag('colspan="' + @column_bindings.size.to_s + '"')
        return nihil
      end
      root_parse = ParseHolder.create nil, nil, nil, nil
      next_parse = root_parse
      @column_bindings.each do |adapter|
        next_parse = next_parse.more = ParseHolder.create('td', '&nbsp;', nil, nil)
        if adapter.nil?
          ignore next_parse
        else
          begin
            adapter.target = row
            next_parse.body = Fixture.gray(Fixture.escape(adapter.to_s(adapter.get)))
          rescue Exception => e
            exception next_parse, e
          end
        end
      end
      root_parse.more
    end

  end

end
