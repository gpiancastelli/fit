# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'eg/music/music'

module Eg
  module Music

    class MusicLibrary
      @@library = []
      @@looking = nil
      def MusicLibrary.library
        @@library
      end
      def MusicLibrary.looking
        @@looking
      end

      def MusicLibrary.load name
        music = []
        f = File.new(name)
        f.each_line { |line| music << Music.parse(line) if f.lineno > 1 } # skip column headings
        f.close
        @@library = music
      end
      def MusicLibrary.select music
        @@looking = music
      end
      def MusicLibrary.display_count
        count = 0
        @@library.each {|music| count += music.selected ? 1 : 0}
        count
      end
      def MusicLibrary.display_contents
        displayed = []
        @@library.each {|music| displayed << music if music.selected?}
        displayed
      end

      def MusicLibrary.search seconds
        Music.status = 'searching'
        Simulator.next_search_complete = Simulator.schedule seconds
      end
      def MusicLibrary.search_complete
        Music.status = (MusicPlayer.playing.nil?) ? 'ready': 'playing'
      end
      def MusicLibrary.find_all
        MusicLibrary.search 3.2
        @@library.each {|music| music.selected = true}
      end
      def MusicLibrary.find_artist author
        MusicLibrary.search 2.3
        @@library.each {|music| music.selected = (music.artist == author)}
      end
      def MusicLibrary.find_album album
        MusicLibrary.search 1.1
        @@library.each {|music| music.selected = (music.album == album)}
      end
      def MusicLibrary.find_genre genre
        search 0.2
        @@library.each {|music| music.selected = (music.genre == genre)}
      end
      def MusicLibrary.find_year year
        search 0.8
        @@library.each {|music| music.selected = (music.year == year)}
      end
    end

  end
end
