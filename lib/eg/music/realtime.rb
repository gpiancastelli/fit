# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/timed_action_fixture'
require 'eg/music/simulator'

module Eg
  module Music

    class Realtime < Fit::TimedActionFixture
      def initialize
        super
        @system = Simulator.system
        @system.reset
      end
      def time; Time.at(Simulator.time); end
      def pause; @system.delay(cells.more.text.to_f); end
      def await; system('wait', cells.more); end
      def fail; system('fail', cells.more); end
      def enter
        @system.delay 0.8
        super
      end
      def press
        @system.delay 1.2
        super
      end
      def system prefix, cell
        method_name = Fit::Fixture.camel "#{prefix} #{cell.text}"
        begin
          @system.send(method_name)
        rescue Exception => e
          exception cell, e
        end
      end
    end

  end
end
