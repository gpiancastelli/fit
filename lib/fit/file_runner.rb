# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'
require 'fit/parse'

require 'fileutils' # for report generation

module Fit

  class FileRunner
    attr_accessor :input, :tables, :fixture, :output

    def initialize
      @fixture = Fixture.new
    end

    def run args
      process_args args
      process
      $stderr.puts @fixture.totals
      exit @fixture.total_errors
    end

    def process_args args
      error "no input file" if args[0].nil?
      input_name = File.expand_path args[0]
      begin
        input_file = File.open input_name
      rescue Errno::ENOENT
        error "#{input_name}: file not found"
      end
      error "no output file" if args[1].nil?
      output_name = File.expand_path args[1]
      FileUtils.mkpath File.dirname(output_name)
      @output = File.open output_name, 'w'
      @fixture.summary['input file'] = input_name
      @fixture.summary['input update'] = input_file.mtime.to_s
      @fixture.summary['output file'] = output_name
      @input = input_file.read
      input_file.close
    end

    def process
      begin
        unless @input.index('<wiki>').nil?
          @tables = Parse.new @input, ['wiki', 'table', 'tr', 'td']
          @fixture.do_tables @tables.parts
        else
          @tables = Parse.new @input, ['table', 'tr', 'td']
          @fixture.do_tables @tables
        end
      rescue Exception => e
        exception e
      end
      @tables.print @output
      @output.close
    end

    def exception e
      @tables = ParseHolder.create 'body', 'Unable to parse input. Input ignored.', nil, nil
      @fixture.exception @tables, e
    end

    def error msg
      $stderr.puts "#{File.basename($0)}: #{msg}"
      exit -1
    end

    protected :exception, :error

  end

end

# The main loop of the program
# if __FILE__ == $0
#   begin
#     Fit::FileRunner.new.run ARGV
#   rescue Exception => e
#     $stderr.puts e.message
#     exit -1
#   end
# end
