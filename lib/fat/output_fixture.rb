# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fat

  class OutputFixture < Fit::ColumnFixture
    attr_accessor :text
    def cell_output
      cell = Fit::ParseHolder.create 'td', '', nil, nil
      cell.leader = ''
      cell.body = Fit::Fixture.escape unescape(@text)
      generate_output cell
    end
    def unescape text
      text.gsub(/\\n/, "\n").gsub(/\\r/, "\r")
    end
    def generate_output parse
      result = StringWriter.new
      parse.print result
      result.to_s
    end
    private :unescape, :generate_output
    class StringWriter
      def initialize; @s = ''; end
      def print s; @s += s; end
      def to_s; @s; end
    end
  end

end
