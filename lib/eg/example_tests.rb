# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Eg

  class ExampleTests < Fit::ColumnFixture
    attr_accessor :file, :wiki
    attr_accessor :tables, :fixture, :run_counts, :input, :footnote
    protected :tables, :tables=, :fixture, :fixture=, :run_counts, :run_counts=
    attr_accessor :footnote, :input
    protected :footnote, :footnote=, :input, :input=

    def initialize
      @run_counts = Fit::Counts.new
      @footnote = nil
    end

    def wiki?; @wiki; end

    def run
      input = File.open("../../examples/#@file") {|f| f.read}
      @fixture = Fit::Fixture.new
      if wiki?
        @tables = Fit::Parse.new input, ['wiki', 'table', 'tr', 'td']
        @fixture.do_tables @tables.parts
      else
        @tables = Fit::Parse.new input, ['table', 'tr', 'td']
        @fixture.do_tables @tables
      end
      @run_counts.tally @fixture.counts
      @summary['counts run'] = @run_counts.to_s
    end
    protected :run

    # The right method is more complicated than the one in the original
    # Java FIT version because Ruby does not see different methods based
    # on the number of their arguments: here, ExampleTests#right shadows
    # Fixture#right, so it must serve two roles at the same time.
    def right arg0 = nil
      unless arg0.nil?
        super
      else
        run
        @fixture.counts.right
      end
    end

    def ignores
      @fixture.counts.ignores
    end

    def exceptions
      @fixture.counts.exceptions
    end

    # Footnote

    def do_row row
      @file_cell = row.leaf
      super
    end

    # The wrong method is more complicated than the one (two, actually)
    # in the original Java FIT version because Ruby does not see different
    # methods based based on the number of their arguments: here, the
    # method ExampleTests#wrong shadows Fixture#wrong, so it must serve
    # two (three, actually) roles at the same time.
    def wrong cell = nil, actual = nil
      if cell.nil?
        @fixture.counts.wrong
      else
        super
        if @footnote.nil?
          @footnote = @tables.footnote
          @file_cell.add_to_body footnote
        end
      end
    end
    
  end

end
