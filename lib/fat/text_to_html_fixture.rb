# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'fit/fixture'

module Fat

  class TextToHtmlFixture < Fit::ColumnFixture
    attr_accessor :text
    def html
      @text = unescape_ascii @text
      Fit::Fixture.escape @text
    end
    def unescape_ascii text
      text.gsub(/\\n/, "\n").gsub(/\\r/, "\r")
    end    
    private :unescape_ascii
  end

end