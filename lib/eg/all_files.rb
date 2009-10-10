# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'fit/fixture'

module Eg

  class AllFiles < Fit::Fixture
    @@file_stack = []
    def do_row row
      cell = row.leaf
      files = expand cell.text
      if files.size > 0
        do_row_files row, files
      else
        ignore cell
        cell.add_to_body Fit::Fixture.gray('no match')
      end
    end
    def expand pattern; Dir[pattern].sort; end
    protected
    def do_row_files row, files; do_files row, files; end
    def do_files row, files
      files.each do |filename|
        cells = td(File.basename(filename), td('', nil))
        row = (row.more = tr(cells, row.more))
        fixture = Fit::Fixture.new
        run(filename, fixture, cells)
        summarize(fixture, filename)
      end
    end
    def run filename, fixture, cells
      if push_and_check(filename)
        ignore cells
        cells.add_to_body Fit::Fixture.gray('recursive')
        return
      end
      begin
        input = File.open(filename) {|f| f.read}
        if input.index('<wiki>')
          tables = Fit::Parse.new(input, ['wiki', 'table', 'tr', 'td'])
          fixture.do_tables tables.parts
        else
          tables = Fit::Parse.new(input, ['table', 'tr', 'td'])
          fixture.do_tables tables
        end
        cells.more.add_to_body Fit::Fixture.gray(fixture.totals)
        if fixture.total_errors.zero?
          right cells.more
        else
          wrong cells.more
          cells.more.add_to_body tables.footnote
        end
      rescue Exception => e
        exception cells, e
      end
      pop filename
    end
    def push_and_check filename
      return true if @@file_stack.member? filename
      @@file_stack << filename
      false
    end
    def pop filename; @@file_stack.delete filename; end
    def tr cells, more
      Fit::ParseHolder.create('tr', nil, cells, more)
    end
    def td text, more
      Fit::ParseHolder.create('td', Fit::Fixture.gray(text), nil, more)
    end
    private
    def summarize fixture, filename
      fixture.summary['input file'] = filename
      fixture.summary['input update'] = File.open(filename) {|f| f.mtime.to_s}
      run_totals = @summary.include?('counts run') ? @summary['counts run'] : Fit::Counts.new
      run_totals.tally fixture.counts
      @summary['counts run'] =  run_totals
    end
    # Self test.
    class Expand < Fit::ColumnFixture
      attr_accessor :path
      def initialize
        super
        @fixture = AllFiles.new
      end
      def expansion
        files = @fixture.expand @path
        files.sort.collect {|filename| File.basename(filename)}
      end
    end
  end

end
