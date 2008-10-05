# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'eg/music/simulator'
require 'eg/music/music_library'

module Eg
  module Music

    class MusicPlayer

      @@playing = nil
      @@paused = 0

      def MusicPlayer.playing; @@playing; end
      
      # Controls
      
      def MusicPlayer.play music
        if @@paused.zero?
          Music.status = 'loading'
          seconds = (music == @@playing) ? 0.3 : 2.5
          Simulator.next_play_started = Simulator.schedule seconds
        else
          Music.status = 'playing'
          Simulator.next_play_complete = Simulator.schedule @@paused
          @@paused = 0
        end
      end

      def MusicPlayer.pause
        Music.status = 'pause'
        if (not @@playing.nil?) and @@paused.zero?
          @@paused = (Simulator.next_play_complete - Simulator.time)
          Simulator.next_play_complete = 0
        end
      end

      def MusicPlayer.stop
        Simulator.next_play_started = 0
        Simulator.next_play_complete = 0
        play_complete
      end

      # Status

      def MusicPlayer.seconds_remaining
        if not @@paused.zero?
          return @@paused
        elsif not @@playing.nil?
          return (Simulator.next_play_complete - Simulator.time)
        else
          return 0
        end
      end

      def MusicPlayer.minutes_remaining
        (MusicPlayer.seconds_remaining / 0.6).ceil / 100.0
      end

      # Events
      
      def MusicPlayer.play_started
        Music.status = 'playing'
        @@playing = MusicLibrary.looking
        Simulator.next_play_complete = Simulator.schedule @@playing.seconds
      end

      def MusicPlayer.play_complete
        Music.status = 'ready'
        @@playing = nil
      end

    end

  end
end
