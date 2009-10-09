# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'
require 'fit/parse'

require 'fileutils' # for report generation
require 'iconv' # for I/O encoding
require 'stringio' # to help fix any possibly invalid byte sequence

module Fit

  class FileRunner
    attr_accessor :input, :tables, :fixture, :output

    def initialize
      @fixture = Fixture.new
      @encoding = nil
    end

    def run args, opts=nil
      @encoding = opts[:encoding] unless opts.nil?
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
      unless @encoding.nil?
        conv = Iconv.new 'UTF-8', @encoding
        @input = conv.iconv(input_file.read)
        @input << conv.iconv(nil)
      else
        @input = input_file.read
      end
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
      unless @encoding.nil?
        buffer = StringIO.new
        conv = Iconv.new 'UTF-8//IGNORE', 'UTF-8'
        @tables.print buffer, conv
        buffer.print conv.iconv(nil)
        conv = Iconv.new @encoding, 'UTF-8'
        @output.print conv.iconv(buffer.string)
        @output << conv.iconv(nil)
        buffer.close
      else
        @tables.print @output
      end
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
