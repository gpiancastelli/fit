# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/action_fixture'

module Fit

  class TimedActionFixture < ActionFixture
    attr_accessor :format
    def initialize
      super
      @format = '%H:%M:%S'
    end
    def do_table table
      super
      table.parts.parts.last.more = td('time')
      table.parts.parts.last.more = td('split')
    end
    def do_cells cells
      start = time
      super
      split = time - start
      cells.last.more = td(start.strftime(@format))
      cells.last.more = td(split < 1 ? '&nbsp;' : sprintf("%1.1f", split))
    end
    # Utility
    def td body
      ParseHolder.create('td', Fixture.gray(body), nil, nil)
    end
    def time
      Time.now
    end
  end

end
