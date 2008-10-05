# Copyright (c) 2003 Rick Mugridge, University of Auckland, NZ
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fitlibrary
  module Specify
  
  class ColumnFixtureUnderTest < Fit::ColumnFixture
    attr_accessor :camel_field_name
    def get_camel_field_name
      @camel_field_name
    end
  end
  
  end
end