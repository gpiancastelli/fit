# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fat

  class HtmlToTextFixture < Fit::ColumnFixture
    @@metadata = {'html' => String}
    attr_writer :html
    def text
      html = @html.gsub(/\\u00a0/, [0x00a0].pack('U'))
      escape_ascii(Fit::Parse.html_to_text(html))
    end
    def escape_ascii text
      text.gsub([0x0a].pack('U'), "\\n").gsub([0x0d].pack('U'), "\\r").gsub([0xa0].pack('U'), " ")
    end
  end

end
