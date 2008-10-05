# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/file_runner'

$stderr.puts 'WikiRunner is deprecated: use FileRunner'

if __FILE__ == $0
  begin
    Fit::FileRunner.new.run ARGV
  rescue Exception => e
    $stderr.puts e.message
    exit -1
  end
end
