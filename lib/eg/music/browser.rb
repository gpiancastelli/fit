# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'
require 'eg/music/music_library'
require 'eg/music/music_player'

module Eg
  module Music

    class Browser < Fit::Fixture
      
      # Library

      def library path
        filename = path[path.rindex('/')..-1]
        MusicLibrary.load File.join(File.dirname(__FILE__), filename)
      end

      def total_songs
        MusicLibrary.library.size
      end

      # Select details

      def playing; MusicPlayer.playing.title; end
      
      def select index
        MusicLibrary.select MusicLibrary.library[index - 1]
      end

      def title; MusicLibrary.looking.title; end
      def artist; MusicLibrary.looking.artist; end
      def album; MusicLibrary.looking.album; end
      def year; MusicLibrary.looking.year; end
      def time; MusicLibrary.looking.time; end
      def track; MusicLibrary.looking.track; end

      # Search buttons

      def same_album; MusicLibrary.find_album(MusicLibrary.looking.album); end
      def same_artist; MusicLibrary.find_artist(MusicLibrary.looking.artist); end
      def same_genre; MusicLibrary.find_genre(MusicLibrary.looking.genre); end
      def same_year; MusicLibrary.find_year(MusicLibrary.looking.year); end
      
      def selected_songs; MusicLibrary.display_count; end

      def show_all; MusicLibrary.find_all; end

      # Play buttons

      def play; MusicPlayer.play(MusicLibrary.looking); end
      def pause; MusicPlayer.pause; end
      def status; Music.status; end
      def remaining; MusicPlayer.minutes_remaining; end

    end

  end
end
