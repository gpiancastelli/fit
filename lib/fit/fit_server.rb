# Written by Object Mentor, Inc. 2005
# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'
require 'fit/parse'
require 'fit/fit_protocol'
require 'socket'

module Fit
  
  class FitServer
  
    attr_accessor :host, :port, :test_ticket, :verbose
    attr_reader :reason_for_bad_connection, :counts
  
    def run(args)
      if args(args)
        connected = establish_connection
        if not connected
          puts "Could not connect. " + @reason_for_bad_connection
          return -1
        else
          process
          close_connection
          finish
          return exit_code
        end
      else
        usage
        return -1
      end    
    end

    def args(arg_list)
      begin
        arg_count = arg_list.size
        if arg_count == 4 and  arg_list.shift == '-v'
          @verbose = true
        elsif arg_count != 3
          return false
        end
        @host = arg_list.shift
        @port = arg_list.shift.to_i
        return false if @port.zero?;
        @test_ticket = arg_list.shift
        return true
      rescue => exception
        return false
      end
    end
  
    def usage
      puts "Usage: ruby FitServer.rb [options] <host> <port> <test_ticket>"
      puts "  -v: verbose"
    end
    
    def build_request
      return "GET /?responder=socketCatcher&ticket=" + @test_ticket + " HTTP/1.1\r\n\r\n"
    end
    
    def close_connection
      @socket.close
    end
    
    def establish_connection
      say "Connecting to " + @host.to_s + ":" + @port.to_s
      @socket = TCPSocket.new(@host, @port)
      @socket.print(build_request)
      @socket.flush
      status = FitProtocol.read_size(@socket)
      unless status.zero?
        @reason_for_bad_connection = FitProtocol.read(status, @socket)
        say "\t> failed to connect: " + @reason_for_bad_connection
        return false
      else
        say "\t> connected"
        return true
      end
    end
    
    def process
      @fixture_listener = TablePrintingFixtureListener.new(@socket)
      @counts = Counts.new
      document_size = 0
      begin
        while ((document_size = FitProtocol.read_size(@socket)) != 0)
          begin
            say "Processing document with " + document_size.to_s + " bytes"
            document = FitProtocol.read(document_size, @socket)
            tables = Parse.new(document, ['table', 'tr', 'td'])
            new_fixture
            @fixture.do_tables(tables)
            say "\t> " + @fixture.counts.to_s
            @counts.tally(@fixture.counts)
          rescue Fit::ParseException => e
            exception(e)
          end
        end
      rescue => e
        exception(e)
      end
    end
    
    def new_fixture
      @fixture = Fixture.new
      @fixture.listener = @fixture_listener
    end
    
    def good_connection?
      return reason_for_bad_connection.nil?
    end
    
    def finish
      say "Final counts: " + @counts.to_s
      say "Exiting with code " + exit_code().to_s
    end
    
    def exit_code()
      return @counts.wrong + @counts.exceptions
    end
    
    def say(message)
      puts message if @verbose
    end
    
    def exception(e)
      say "Exception occured!"
      say "\t> " + e.to_s
      parse = ParseHolder.create("span",  "Exception occurred: ", nil, nil)
      if @fixture.nil?
        new_fixture
      end
      @fixture.exception(parse, e)
      @counts.exceptions = @counts.exceptions + 1
      @fixture_listener.table_finished(parse)
      @fixture_listener.tables_finished(@fixture.counts)
    end
    
  end  

  class PrintString
    def initialize; @buffer = ''; end
    def print text; @buffer += text; end
    def to_s; @buffer; end
  end
  
  class TablePrintingFixtureListener
    def initialize(socket)
      @socket = socket
    end
    
    def table_finished(tableParse)
      buffer = PrintString.new
      print_table(tableParse, buffer)
      FitProtocol.write_document(buffer.to_s, @socket)
    end
    
    def print_table(table, output)
      more = table.more
      table.more = nil
      if table.trailer.nil?
        table.trailer = ""
      end
      table.print(output)
      table.more = more
    end
    
    def tables_finished(counts)
      FitProtocol.write_counts(counts, @socket)
    end
  end
end
