# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

module Fat

  class StringWriter
    def initialize; @s = ''; end
    def print s; @s += s.to_s; end
    def to_s; @s; end
  end

end
