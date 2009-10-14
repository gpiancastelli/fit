# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/scientific_double'
require 'fit/fixture_loader'

require 'date'

module Fit

  class RunTime
    def initialize
      @elapsed = 0
      @start = Time.now
    end
    def to_s
      @elapsed = Time.now.to_f - @start.to_f
      if @elapsed > 1
        @elapsed = @elapsed.round
        return d(3600) + ':' + d(600) + d(60) + ':' + d(10) + d(1)
      else
        @elapsed = (@elapsed * 100).round
        return d(6000) + ':' + d(1000) + d(100) + '.' + d(10) + d(1)
      end
    end
    def d scale
      report = @elapsed / scale
      @elapsed -= report * scale
      report.to_s
    end
  end

  class Counts
    attr_accessor :right, :wrong, :ignores, :exceptions
    def initialize
      @right, @wrong, @ignores, @exceptions = 0, 0, 0, 0
    end
    def to_s
      "#@right right, #@wrong wrong, #@ignores ignored, #@exceptions exceptions"
    end
    def tally c
      @right += c.right
      @wrong += c.wrong
      @ignores += c.ignores
      @exceptions += c.exceptions
    end
    def total_errors
      @wrong + @exceptions
    end
  end
  
  class FixtureListener
    def tables_finished(finalCounts)
    end
    
    def table_finished(tableParse)
    end
  end

  class Fixture
    @@metadata = {}
    def Fixture.metadata; @@metadata; end

    @@loader = FixtureLoader.new

    attr_accessor :summary, :counts, :listener, :args

    def initialize
      @summary = {}
      @counts = Counts.new
      @listener = FixtureListener.new
      @args = []
    end

    def total_errors
      @counts.total_errors
    end
    
    # Traversal

    def find_class class_name
      @@loader.find_fixture_class class_name
    end
    
    def do_tables tables
      @summary['run date'] = Time.now.to_s
      @summary['run elapsed time'] = RunTime.new
      unless tables.nil?
        fixture_name = fixture_name tables
        unless fixture_name.nil?
          begin
            fixture = get_linked_fixture_with_args tables
            fixture.interpret_tables tables
          rescue Exception => e
            exception fixture_name, e
            @listener.table_finished(tables)
            interpret_following_tables tables
          end
        end
      end
      @listener.tables_finished(@counts)
    end
    
    def interpret_tables tables
      # don't create the first fixture again, because creation may do something important
      begin
        get_args_for_table(tables) # get them again for the new fixture object
        do_table tables
      rescue Exception => e
        exception fixture_name(tables), e
        return
      end
      @listener.table_finished(tables)
      interpret_following_tables tables
    end
    
    def interpret_following_tables tables
      tables = tables.more
      until tables.nil?
        fixture_name = fixture_name(tables)
        unless fixture_name.nil?
          begin
            fixture = get_linked_fixture_with_args tables
            fixture.do_table tables
          rescue Exception => e
            exception fixture_name, e
          end
        end
        @listener.table_finished(tables)
        tables = tables.more
      end
    end
    
    def get_linked_fixture_with_args tables
      header = fixture_name tables
      unless header.nil?
        begin
          fixture = (find_class header.text).new # using reflection
          fixture.summary = @summary
          fixture.counts = @counts
          fixture.listener = @listener
          fixture.get_args_for_table tables
          return fixture
        rescue Exception => e
          exception header, e
        end
      end
    end
    
    def get_args_for_table table
      arg = table.parts.parts.more
      args = []
      while arg
        args << arg.text
        arg = arg.more
      end
      @args = args
    end
    
    def fixture_name tables
      tables.at 0, 0, 0
    end
    
    def do_table table
      do_rows table.parts.more
    end

    def do_rows rows
      until rows.nil?
        more = rows.more
        do_row rows
        rows = more
      end
    end

    def do_row row
      do_cells row.parts
    end

    def do_cells cells
      i = 0
      until cells.nil?
        begin
          do_cell cells, i
        rescue Exception => e
          exception cells, e
        end
        cells = cells.more
        i += 1
      end
    end

    def do_cell cell, column_number
      ignore cell
    end

    # Annotation methods
    GREEN = '#cfffcf'
    RED = '#ffcfcf'
    GRAY = '#efefef'
    YELLOW = '#ffffcf'

    def right cell
      cell.add_to_tag(' bgcolor="' + GREEN + '"')
      @counts.right += 1
    end

    def wrong cell, actual = nil
      cell.add_to_tag(' bgcolor="' + RED + '"')
      cell.body = Fixture.escape(cell.text)
      @counts.wrong += 1
      unless actual.nil?
        cell.add_to_body(Fixture.label('expected') + '<hr>' + Fixture.escape(actual) + Fixture.label('actual'))
      end
    end

    def ignore cell
      cell.add_to_tag(' bgcolor="' + GRAY + '"')
      @counts.ignores += 1
    end

    def exception cell, e
      stacktrace = e.backtrace.join "\n"
      message = e.message.gsub(/>/, '&gt;').gsub(/</, '&lt;')
      cell.add_to_body "<hr><font size=-2><pre>#{message}\n#{stacktrace}</pre></font>"
      cell.add_to_tag(' bgcolor="' + YELLOW + '"')
      @counts.exceptions += 1
    end
    
    def info cell, message
      string = ' <font color="#808080">' + Fixture.escape(message) + '</font>'
      cell.add_to_body string
    end
    
    def error cell, message
      cell.body = Fixture.escape(cell.text)
      cell.add_to_body('<hr><pre>' + Fixture.escape(message) + '</pre>')
      cell.add_to_tag(' bgcolor="' + YELLOW + '"')
      @counts.exceptions += 1
    end
    
    # Utility methods
    
    # This method was originally called counts, but the name has been
    # changed to avoid shadowing the counts accessor attribute.
    def totals
      @counts.to_s
    end

    def Fixture.label s
      ' <font size=-1 color="#c08080"><i>' + s + '</i></font>'
    end

    def Fixture.gray s
      ' <font color="#808080">' + s + '</font>'
    end

    def Fixture.escape s
      str = s.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/  /, ' &nbsp;')
      # str.gsub(/\r\n/, '<br />').gsub(/\n\r/, '<br />').gsub(/\r/, '<br />').gsub(/\n/, '<br />')
      str.gsub(/\r\n/, '<br />').gsub(/\r/, '<br />').gsub(/\n/, '<br />')
    end

    # Originally, this method built the name of a Java method from multiple,
    # space-separated, downcased words, morphing them into a single camelcased
    # word. Ruby just needs those words to be joined with an underscore. For
    # historical reasons, this method still maintains its original name.
    def Fixture.camel name
      name.gsub(/ /, '_')
    end

    def parse string, klass
      if klass == Date
        d = Date._parse string
        return [d[:year], d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:zone], d[:wday]] 
      end
      return ScientificDouble.value_of(string) if klass == ScientificDouble
      return string if klass == String
      nil
    end

    def check cell, adapter
      text = cell.text
      if text.empty?
        begin
          info cell, adapter.to_s(adapter.get)
        rescue Exception
          info cell, 'error'
        end
      elsif adapter.nil?
        ignore cell
      elsif text == 'error'
        begin
          result = adapter.invoke # TypeAdapter.invoke does not exist...
          wrong cell, adapter.to_s(result)
        rescue Exception => e
          right cell # no IllegalAccessException?
        end
      else
        begin
          result = adapter.get
          if adapter.equals(adapter.parse(text), result)
            right cell
          else
            wrong cell, adapter.to_s(result)
          end
        rescue Exception => e
          exception cell, e
        end
      end
    end

  end

end
