#!C:/Programmi/Ruby18/bin/ruby

require 'cgi'
require 'open-uri'

# Set the location of the RubyFIT installation on your machine
rubyfit_location = "D:/Progetti/Ruby/Fit/lib"
# Set the location of the newly-created pure-Ruby fixtures on your machine
# rubyfit_fixtures = "D:/Progetti/Ruby/Fit/MyFixtures"
rubyfit_fixtures = "D:/Progetti/Ruby/Fit/examples"

$:.unshift(rubyfit_location, rubyfit_fixtures)

require 'fit/file_runner'

cgi = CGI.new

input_name = 'fitDocument.html'
output_name = 'fitReport.html'

referer = cgi.referer
begin
  input = open(referer) {|stream| stream.read}
  File.open(input_name, 'w') {|f| f.write(input)}
  runner = Fit::FileRunner.new
  runner.process_args [input_name, output_name]
  runner.process

  output = File.open(output_name) {|f| f.read}
  cgi.out { output }

  File.delete(output_name)
  File.delete(input_name)
rescue Exception => e
  cgi.out {e.message + "\n" + e.backtrace.join("\n")}
end