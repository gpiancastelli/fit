# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fat

  class HtmlToTextFixture < Fit::ColumnFixture
    @@metadata = {'html' => String}
    attr_writer :html
    def text
      html = @html.gsub(/\\u00a0/, "\240")
      escape_ascii(Fit::Parse.html_to_text(html))
    end
    def escape_ascii text
      text.gsub("\x0a", "\\n").gsub("\x0d", "\\r").gsub("\xa0", " ")
    end
  end

end