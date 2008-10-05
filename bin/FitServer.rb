$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'fit/fit_server'

exitCode = Fit::FitServer.new.run(ARGV)
exit exitCode