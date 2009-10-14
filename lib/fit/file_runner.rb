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

    DEFAULT_ENCODING = 'UTF-8'

    def initialize
      @fixture = Fixture.new
      @encoding = DEFAULT_ENCODING
    end

    def run args, opts=nil
      @encoding = opts[:encoding].upcase unless opts.nil?
      process_args args
      process
      $stderr.puts @fixture.totals
      exit @fixture.total_errors
    end

    def process_args args
      error "no input file" if args[0].nil?
      input_name = File.expand_path args[0]
      begin
        if input_name.respond_to? :encoding
          input_file = File.open input_name, "r:#@encoding"
        else
          input_file = File.open input_name
        end
      rescue Errno::ENOENT
        error "#{input_name}: file not found"
      end
      output_name = check_output_file args[1]
      create_output_file output_name
      @fixture.summary['input file'] = input_name
      @fixture.summary['input update'] = input_file.mtime.to_s
      @fixture.summary['output file'] = output_name
      unless input_name.respond_to? :encoding
        read_file_with_encoding input_file
      else
        read_file input_file
      end
      input_file.close
    end

    def check_output_file arg
      error "no output file" if arg.nil?
      output_name = File.expand_path arg
    end

    def create_output_file output_name
      FileUtils.mkpath File.dirname(output_name)
      if output_name.respond_to? :encoding
        @output = File.open output_name, "w:#@encoding"
      else
        @output = File.open output_name, 'w'
      end
    end

    def read_file_with_encoding input_file
      if @encoding == DEFAULT_ENCODING
        @input = input_file.read
      else
        conv = Iconv.new DEFAULT_ENCODING, @encoding
        @input = conv.iconv(input_file.read)
        @input << conv.iconv(nil)
      end
    end

    def read_file input_file
      @input = (@encoding == DEFAULT_ENCODING) ? input_file.read : input_file.read.encode(DEFAULT_ENCODING)
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
      if @encoding == DEFAULT_ENCODING
        @tables.print @output
      else
        buffer = StringIO.new
        conv = Iconv.new "#{DEFAULT_ENCODING}//IGNORE", DEFAULT_ENCODING
        @tables.print buffer, conv
        buffer.print conv.iconv(nil)
        conv = Iconv.new "#@encoding//IGNORE", DEFAULT_ENCODING
        @output.print conv.iconv(buffer.string)
        @output << conv.iconv(nil)
        buffer.close
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
