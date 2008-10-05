# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Eg

  class BinaryChop < Fit::ColumnFixture

    attr_accessor :key

    def execute
      @array = [] if @array.nil?
    end

    def array= value
      unless value.kind_of? Array
        @array = [value]
      else
        @array = value
      end
    end
    def array; @array; end

    def result
      chop_friday key, array
    end

    def mon; chop_monday(key, array); end
    def tue; chop_tuesday(key, array); end
    def wed; chop_wednesday(key, array); end
    def thr; chop_thursday(key, array); end
    def fri; chop_friday(key, array); end

    # Search methods

    def chop_monday key, array
      min = 0
      max = array.size - 1
      while min <= max
        probe = (min + max) / 2
        if key == array[probe]
          return probe
        elsif key > array[probe]
          min = probe + 1
        else
          max = probe - 1
        end
      end
      -1
    end

    def chop_tuesday key, array
      min = 0
      max = array.size - 1
      while min <= max
        probe = (min + max) / 2
        case key <=> array[probe]
          when 0 then return probe
          when 1 then min = probe + 1
          when -1 then max = probe - 1
          else raise "Unexpected result from <=>"
        end
      end
      -1
    end

    def chop_wednesday key, array
      return -1 if array.size.zero?
      probe = array.size / 2
      return probe if key == array[probe]
      return chop_wednesday(key, array[0, probe]) if key < array[probe]
      result = chop_wednesday(key, array[(probe + 1)..-1])
      return (result < 0) ? result : result + probe + 1
    end

    def chop_thursday key, array
      min = 0
      max = array.size - 1
      while min <= max
        probe = (rand * (max - min) + min).to_i
        if key == array[probe]
          return probe
        elsif key > array[probe]
          min = probe + 1
        else
          max = probe - 1
        end
      end
      -1
    end

    def chop_friday key, array
      array.each_with_index {|e, i| return i if key == e}
      -1
    end

  end

end
