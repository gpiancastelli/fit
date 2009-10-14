# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'date'

module Eg
  module Music

    class Music
      @@status = 'ready'
      attr_accessor :title, :artist, :album, :genre
      attr_accessor :size, :seconds, :track_number, :track_count, :year
      attr_accessor :date, :selected
      def initialize
        @selected = false
      end

      # Accessors

      def track
        "#{@track_number} of #{@track_count}"
      end

      def time
        (@seconds / 0.6).round / 100.0
      end

      def selected?
        @selected
      end

      def Music.status= value
        @@status = value
      end

      def Music.status; @@status; end

      # Factory
      def Music.parse s
        m = new
        data = s.split(/\t/)
        m.title = data[0]
        m.artist = data[1]
        m.album = data[2]
        m.genre = data[3]
        m.size = data[4].to_i
        m.seconds = data[5].to_i
        m.track_number = data[6].to_i
        m.track_count = data[7].to_i
        m.year = data[8].to_i
        d = Date._parse data[9]
        d_array = [d[:year], d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:zone], d[:wday]] 
        m.date = Time.gm(*d_array.compact)
        m
      end

      alias to_string to_s
      @@metadata = { 'title' => String, 'artist' => String, 'album' => String,
                     'genre' => String, 'size' => Fixnum, 'seconds' => Fixnum,
                     'track_number' => Fixnum, 'track_count' => Fixnum,
                     'year' => Fixnum, 'date' => Time, 'track()' => String,
                     'time()' => Float, 'to_string()' => String
      }
      def Music.metadata; @@metadata; end

    end

  end
end
