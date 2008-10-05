# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'
require 'fit/action_fixture'

module Eg
  module Music

    class Simulator
      @@system = Simulator.new
      @@time = Time.now.to_i
      @@next_search_complete = @@next_play_started = @@next_play_complete = 0
      def Simulator.system
        @@system
      end
      def Simulator.next_search_complete= value
        @@next_search_complete = value
      end
      def Simulator.next_play_started= value
        @@next_play_started = value
      end
      def Simulator.next_play_complete= value
        @@next_play_complete = value
      end
      def Simulator.next_play_complete; @@next_play_complete; end
      def Simulator.time; @@time; end
      def reset
        @@next_search_complete = @@next_play_started = @@next_play_complete = 0
        MusicPlayer.stop
      end
      def next_event bound
        result = bound
        result = sooner result, @@next_search_complete
        result = sooner result, @@next_play_started
        result = sooner result, @@next_play_complete
        result
      end
      def sooner soon, event
        (event > @@time and event < soon) ? event : soon
      end
      def perform
        MusicLibrary.search_complete if @@time == @@next_search_complete
        MusicPlayer.play_started if @@time == @@next_play_started
        MusicPlayer.play_complete if @@time == @@next_play_complete
      end
      def advance future
        while @@time < future
          @@time = next_event future
          perform
        end
      end
      def Simulator.schedule seconds
        @@time + seconds
      end
      def delay seconds
        advance(Simulator.schedule(seconds))
      end
      def wait_search_complete; advance(@@next_search_complete); end
      def wait_play_started; advance(@@next_play_started); end
      def wait_play_complete; advance(@@next_play_complete); end
      def fail_load_jam
        Fit::ActionFixture.actor = Dialog.new('load jamed', Fit::ActionFixture.actor)
      end
    end

    class Dialog < Fit::Fixture
      attr_reader :message
      def initialize message, caller
        super()
        @message = message
        @caller = caller
      end
      def ok
        MusicPlayer.stop if message == 'load jamed'
        Fit::ActionFixture.actor = @caller
      end
    end

  end
end
