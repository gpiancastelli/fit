# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/row_fixture'

require 'date'

module Eg
  module Music

    class Display < Fit::RowFixture
      def get_target_class; Music; end
      def query; MusicLibrary.display_contents; end
      def parse string, klass
        if klass == Time
          d = Date._parse string
          d_array = [d[:year], d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:zone], d[:wday]] 
          Time.gm(*d_array.compact)
        else
          super
        end
      end
    end

  end
end
