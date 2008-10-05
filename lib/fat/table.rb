# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'
require 'fit/parse'

module Fat

  class Table < Fit::Fixture
    @@table = nil
    def Table.table; @@table; end
    def Table.table= table; @@table = table; end
    def do_rows rows
      @@table = Fit::ParseHolder.create('table', nil, Table.copy(rows), nil)
      # evaluate the rest of the table like a runner
      Fit::Fixture.new.do_tables @@table
    end
    def Table.copy tree
      tree.nil? ? nil : Fit::ParseHolder.create(tree.tag, tree.body, Table.copy(tree.parts), Table.copy(tree.more))
    end
  end

end
