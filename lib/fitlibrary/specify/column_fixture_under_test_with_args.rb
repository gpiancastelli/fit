# Copyright (c) 2003 Rick Mugridge, University of Auckland, NZ
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fitlibrary
  module Specify
  
  class ColumnFixtureUnderTestWithArgs < Fit::ColumnFixture
    attr_accessor :third
    def sum
      @args[0].to_i + @args[1].to_i + @third
    end
  end
  
  end
end