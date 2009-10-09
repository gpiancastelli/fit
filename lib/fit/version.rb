# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

module Fit
  VERSION = '1.2'

  VERSION_BLURB = <<EOF_VERSION_BLURB
RubyFIT v#{Fit::VERSION}
Conforms to Fit Specification v1.2
Copyright (C) 2006-9 Giulio Piancastelli
License GPLv2+: GNU GPL version 2 or later
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF_VERSION_BLURB

  HELP_BLURB = <<EOF_HELP_BLURB
usage: #{File.basename($0)} [options] infile outfile

Options:
  --encoding=CHARENC   read and write files using specified character encoding
  --version            print version number
  --help               show this help screen

See http://fit.rubyforge.org for further information and to report bugs
EOF_HELP_BLURB
end
