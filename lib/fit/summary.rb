# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

module Fit

  class Summary < Fixture
    @@counts_key = 'counts'

    def do_table table
      @summary[@@counts_key] = totals
      table.parts.more = rows @summary.keys.sort
    end

    protected

    def rows keys
      return nil if keys.empty?
      key = keys.shift
      result = tr(td(key, td(summary[key].to_s, nil)), rows(keys))
      mark(result) if key == @@counts_key
      result
    end

    def tr parts, more
      ParseHolder.create('tr', nil, parts, more)
    end

    def td body, more
      ParseHolder.create('td', Fixture.gray(body), nil, more)
    end

    # Mark summary good or bad without counting
    def mark row
      official = @counts
      @counts = Counts.new # use a fake results holder to avoid counting
      cell = row.parts.more
      if official.total_errors > 0
        wrong cell
      else
        right cell
      end
      @counts = official
    end
  end

end
