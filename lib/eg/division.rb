# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Eg

  class Division < Fit::ColumnFixture
    attr_accessor :numerator, :denominator
    def quotient; @numerator.to_f / @denominator.to_f; end
  end

end
