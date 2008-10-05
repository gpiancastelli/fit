# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

module Fat

  class Money
    attr_accessor :cents
    def initialize string
      stripped = ''
      string.each {|char| stripped += char if char.between?('0', '9') or char == '.'}
      @cents = (100 * stripped.to_f).to_i
    end
    def == money
      @cents == money.cents
    end
  end

end
