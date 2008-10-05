# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'eg/all_files'

module Eg

  class AllCombinations < AllFiles
    def initialize
      super
      @lists = []
      @case_number = 1
    end
    def do_table table
      @row = table.parts.last
      super
      combinations
    end
    protected
    def do_row_files row, files
      @lists << files
    end
    def combinations index = 0, combination = @lists
      if index == @lists.size
        do_case combination
      else
        files = @lists[index]
        files.each do |f|
          comb = combination.dup
          comb[index] = f
          combinations(index + 1, comb)
        end
      end
    end
    def do_case combination
      number = tr(td('#' + @case_number.to_s, nil), nil)
      @case_number += 1
      number.leaf.add_to_tag 'colspan="2"'
      @row.last.more = number
      do_files number, combination
    end
  end

end
