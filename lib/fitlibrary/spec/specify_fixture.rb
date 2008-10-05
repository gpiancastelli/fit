# Copyright (c) 2005 Rick Mugridge, University of Auckland, NZ
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'

module Fitlibrary
  module Spec
  
    # Uses embedded tables to specify how fixtures work, based on simple
    # subclasses of those fixtures.
    # The test and the report can be in two separate rows, or in a single row.
    class SpecifyFixture < Fit::Fixture
    
      def do_table table
        first_row = table.parts.more
        actual = first_row.parts.parts
        second_row = first_row.more
        expected_cell = second_row.nil? ? first_row.parts.more : second_row.parts
        expected = expected_cell.parts
        Fit::Fixture.new.do_tables(actual)
        if reports_equal(actual, expected)
          right expected_cell
        else
          wrong expected_cell
          print_parse actual, 'actual'
          add_table_to_better_show_differences table, actual, expected
        end
      end
      
      def add_table_to_better_show_differences table, actual, expected
        parse_end = table.last
        cells1 = Fit::ParseHolder.create('td', 'fitlibrary.CommentFixture', nil, nil)
        cells2 = Fit::ParseHolder.create('td', 'actual', nil, Fit::ParseHolder.create('td', 'expected', nil, nil))
        cells3 = Fit::ParseHolder.create('td', show(actual), nil, Fit::ParseHolder.create('td', show(expected), nil, nil))
        rows = Fit::ParseHolder.create('tr', '', cells1, Fit::ParseHolder.create('tr', '', cells2, Fit::ParseHolder.create('tr', '', cells3, nil)))
        parse_end.more = Fit::ParseHolder.create('table', '', rows, nil)
      end
      
      def show parse
        return 'nil' if parse.nil?
        result = "&lt;#{parse.tag[0..-2]}&gt;<ul>"
        result += show_field('leader', parse.leader)
        result += parse.parts.nil? ? show_field('body', parse.body) : show(parse.parts)
        result += show_field('trailer', parse.trailer)
        result += '</ul>'
        result += show(parse.more) unless parse.more.nil?
        result
      end
      
      def show_field field, value
        if (not value.nil?) and (not value.strip.empty?)
          "<li>#{field}: '#{no_tags(value)}'"
        else
          ""
        end
      end
      
      def no_tags value
        while true
          index = value.index '<'
          break if index < 0
          value = value[0..index] + '&lt;' + value[index + 1..-1]
        end
        value
      end
      
      def reports_equal actual, expected
        return expected.nil? if actual.nil?
        return false if expected.nil?
        massage_body_to_table actual
        result = equal_tags(actual, expected) and
                 equal_strings(actual.leader, expected.leader) and
                 equal_bodies(actual, expected) and
                 equal_strings(actual.trailer, expected.trailer) and
                 reports_equal(actual.more, expected.more) and
                 reports_equal(actual.parts, expected.parts)
        result
      end
      
      def massage_body_to_table actual
        if (not actual.body.nil?) and (not actual.body.index('<table').nil?)
          if actual.parts.nil?
            begin
              actual.parts = Fit::Parse.new actual.body
            rescue Exception => e # FIXME FitParseException
              # do nothing
            end
          end
          actual.body = ''
        end
      end
      
      def equal_bodies actual, expected
        result = equal_bodies_22 actual, expected
        puts "!SpecifyFixture#equal_bodies(\"#{actual.body}\",\"#{expected.body}\")" unless result
        result
      end
      
      def equal_bodies_22 actual, expected
        expected_body = canonical_string expected.body
        actual_body = canonical_string actual.body
        return true if expected_body == 'IGNORE'
        return true if actual_body == expected_body
        stack_trace = 'class="fit_stacktrace">'
        start = expected_body.index stack_trace
        unless start.nil?
          pattern = expected_body[0, start + stack_trace.size]
          return actual.body =~ pattern
        end
        error_message = '<span class="fit_label">'
        start = expected_body.index error_message
        unless start.nil?
          end_span = expected_body.index '</span>', start
          unless end_span.nil?
            pattern = expected_body[0, end_span - 1]
            return actual.body =~ pattern
          end
        end
        false
      end
      
      def canonical_string body
        s = body.nil? ? '' : body.strip
        s
      end
      
      def equal_tags p1, p2
        p1.tag == p2.tag
      end
      
      def equal_strings actual, expected
        result = equal_strings_22 actual, expected
        puts "!SpecifyFixture#equal_strings(\"#{actual}\",\"#{expected}\")" unless result
        result
      end
      
      def equal_strings_22 actual, expected
        return (expected.nil? or expected.strip.empty? or expected == "\n") if actual.nil?
        return (actual.strip.empty? or actual == "\n") if expected.nil?
        return true if expected == 'IGNORE'
        actual.strip == expected.strip
      end
      
      # FIXME This should go in Fitlibrary::ParseUtility
      def print_parse tables, title
        puts "---------Parse tables for #{title}:----------"
        tables.print(STDOUT) unless tables.nil?
        puts "-------------------"
      end
      
    end
  
  end
end