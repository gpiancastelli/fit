# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'

module Eg
  module Net

    class GeoCoordinate
      attr_accessor :lat, :lon
      @@precision = 0.00001
      def initialize lat, lon
        @lat = lat
        @lon = lon
      end
      def GeoCoordinate.parse string
        coordinates = string.downcase.split(/\s*([wWnNsSeE])\s*|\s/).delete_if {|it| it.size.zero?}
        n = [0, 0, 0, 0, 0, 0]
        i = 0
        north = true; east = true
        coordinates.each do |data|
          c = data[0, 1] # pick the first character
          if c.between?('0', '9') or c == '-'
            n[i] = data.to_f
            i += 1
          end
          north = false if c == 's'
          east = false if c == 'w'
          i = 3 if i > 0 and 'nsew'.index(c)
        end
        lat = n[0] + n[1]/60 + n[2]/3600
        lon = n[3] + n[4]/60 + n[5]/3600
        GeoCoordinate.new(north ? lat : -lat, east ? lon : -lon)
      end
      def == object
        return false unless object.kind_of? GeoCoordinate
        return (@lat / @@precision).to_i == (object.lat / @@precision).to_i &&
               (@lon / @@precision).to_i == (object.lon / @@precision).to_i
      end
      def to_s
        "#{@lat > 0 ? 'N' : 'S'}#{@lat.abs} #{@lon > 0 ? 'E' : 'W'}#{@lon.abs}"
      end
    end
    
    class Simulator < Fit::Fixture
      @@metadata = {'coord' => GeoCoordinate}
      def Simulator.metadata; @@metadata; end
      attr_accessor :zip, :nodes
      def initialize
        super
        @nodes = 0
      end
      def coord= value
        @coord = value
      end
      def coord; @coord; end
      def new_city; end;
      def ok; @nodes += 1; end
      def cancel; end;
      def name s; end;
      def population p; end
      def parse string, klass
        return GeoCoordinate.parse(string) if klass == GeoCoordinate
        super
      end
    end

  end
end
