# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/row_fixture'

require 'parsedate'

module Eg
  module Music

    class Display < Fit::RowFixture
      def get_target_class; Music; end
      def query; MusicLibrary.display_contents; end
      def parse string, klass
        if klass == Time
          Time.gm(*ParseDate.parsedate(string).compact)
        else
          super
        end
      end
    end

  end
end
