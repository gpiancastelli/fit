# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'fat/string_writer'

module Fat

  class StandardAnnotationFixture < Fit::ColumnFixture
  
    attr_accessor :original_html, :annotation, :text

    def initialize
      super
      @original_html = 'Text'
    end

    def output
      parse = Fit::Parse.new @original_html, ['td']
      testbed = Fit::Fixture.new
      case @annotation
        when 'right' then testbed.right(parse)
        when 'wrong' then testbed.wrong(parse, @text)
        when 'error' then testbed.error(parse, @text)
        when 'info' then testbed.info(parse, @text)
        when 'ignore' then testbed.ignore(parse)
        else return "unknown type: #@type"
      end
      generate_output parse
    end

    def do_cell cell, column
      begin
        if column == 4
          cell.body = rendered_output
        else
          super
        end
      rescue Exception => e
        exception cell, e
      end
    end

    def rendered_output
      '<table border="1"><tr>' + output + '</tr></table>'
    end

    # Code smell note: copied from Fat::ParseFixture
    def generate_output parse
      result = StringWriter.new
      parse.print result
      result.to_s
    end

    private :generate_output
  end

end