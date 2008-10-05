# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fat

  class Divide < Fit::ColumnFixture
    attr_accessor :x, :y
    def divide; x / y; end
  end

end
