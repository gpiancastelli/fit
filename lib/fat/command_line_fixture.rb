# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

require 'optparse'

module Fat

  # This is really testing OptionParser rather than some
  # new RubyFIT code, but it's nice to have anyway just
  # in case the Ruby standard library behaviour should
  # change between subsequent versions.
  class CommandLineFixture < Fit::ColumnFixture
    attr_accessor :command_line
    attr_reader :encoding
    def initialize
      @options = OptionParser.new
      @options.on('--encoding=ENC') { |enc| @encoding = enc }
    end
    def input_file
      args()[0]
    end
    def output_file
      args()[1]
    end
    def args
      @encoding = 'Implementation-specific'
      @options.parse(command_line.split)
    end
  end

end
