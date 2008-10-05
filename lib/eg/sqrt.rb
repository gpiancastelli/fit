# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Eg

  class Sqrt < Fit::ColumnFixture
    attr_accessor :value
    def sqrt
      # But Math.sqrt already raise an error if its parameter is less than zero...
      # and in fact this guard clause is present because the java.lang.Math method
      # for sqare radix would return NaN if its argument is negative.
      raise "negative sqrt" if @value < 0
      Math.sqrt @value
    end
  end

end
