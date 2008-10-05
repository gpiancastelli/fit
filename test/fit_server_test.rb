# Written by Object Mentor, Inc. 2005
# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

# Make the test run location independent
$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'socket'
require 'fit/fit_server'

module Fit
  class FitServerTest < Test::Unit::TestCase
  
    def setup
      @fit_server = FitServer.new
      @read_end_of_pipe, @write_end_of_pipe = IO.pipe
    end
    
    def teardown
      @session.close if @session != nil
      @server.close if @server != nil
      @server_thread.kill if @server_thread != nil and @server_thread.alive?
    end
  
    def test_args
      success = @fit_server.args(['localhost', '80', '123'])
      assert(success);
    	check_standard_fit_server_parameters
    end
    
    def test_args_with_verbose
      success = @fit_server.args(['-v', 'localhost', '80', '123'])
      assert(success)
      assert(@fit_server.verbose)
    	check_standard_fit_server_parameters
    end
    
    def test_bad_args
      assert(! @fit_server.args(['-x', 'localhost', '80', '123']))
      assert(! @fit_server.args(['-x', 'localhost', '80']))
      assert(! @fit_server.args(['localhost', '80', '123', 'blah']))
      assert(! @fit_server.args(['localhost', 'abc', '123']))
    end
    
    def check_standard_fit_server_parameters
    	assert_equal('localhost', @fit_server.host)
    	assert_equal(80, @fit_server.port)
    	assert_equal('123', @fit_server.test_ticket)
    end
    
    def test_build_request
    	@fit_server.test_ticket = "12345"
    	expected_request = "GET /?responder=socketCatcher&ticket=12345 HTTP/1.1\r\n\r\n"
    	assert_equal(expected_request, @fit_server.build_request)
    end
    
    def test_read_size
      @write_end_of_pipe.print("0000000000")
    	assert_equal(0, FitProtocol.read_size(@read_end_of_pipe))
      @write_end_of_pipe.print("0000000001")
    	assert_equal(1, FitProtocol.read_size(@read_end_of_pipe))
      @write_end_of_pipe.print("00000123450000000021")
    	assert_equal(12345, FitProtocol.read_size(@read_end_of_pipe))
    	assert_equal(21, FitProtocol.read_size(@read_end_of_pipe))
    end
    
    def test_establish_connection
      startSession do
          @session.print('0000000000')
          @session.flush
      end
      @fit_server.establish_connection()
      assert(@fit_server.good_connection?)
    end
    
    def test_validate_connection
      message = "This would normally be an error message"
      message_length = '00000000' + message.length.to_s
    	startSession do
    	  @session.print(message_length)
    	  @session.print(message)
    	  @session.flush
    	end
      @fit_server.establish_connection()
    	assert(! @fit_server.good_connection?)
    	assert_equal(message, @fit_server.reason_for_bad_connection)
    end
    
    def test_run_one_passing_table
    	startSession do
    	  FitProtocol.write_size(0, @session)
    	  FitProtocol.write_document(passing_table, @session)
    	  FitProtocol.write_size(0, @session)
    	end
      @fit_server.establish_connection()
      @fit_server.process()
      results = FitProtocol.read_document(@session)
      FitProtocol.read_size(@session)
      counts = FitProtocol.read_counts(@session)
      assert_not_nil(results.index("<td bgcolor=\"#cfffcf\">"), results)
      check_counts(counts, 1, 0, 0, 0)
      assert_equal(0, @fit_server.exit_code)
    end
    
    def test_run_one_failing_table
    	startSession do
    	  FitProtocol.write_size(0, @session)
    	  FitProtocol.write_document(failing_table, @session)
    	  FitProtocol.write_size(0, @session)
    	end
      @fit_server.establish_connection()
      @fit_server.process()
      results = FitProtocol.read_document(@session)
      FitProtocol.read_size(@session)
      counts = FitProtocol.read_counts(@session)
      assert_not_nil(results.index("<td bgcolor=\"#ffcfcf\">"), results)
      check_counts(counts, 0, 1, 0, 0)
      assert_equal(1, @fit_server.exit_code)
    end
    
    def test_two_tables_in_one_document
    	startSession do
    	  FitProtocol.write_size(0, @session)
    	  FitProtocol.write_document(passing_table + "\n" + failing_table, @session)
    	  FitProtocol.write_size(0, @session)
    	end
      @fit_server.establish_connection()
      @fit_server.process()
      passing_results = FitProtocol.read_document(@session)
      failing_results = FitProtocol.read_document(@session)
      FitProtocol.read_size(@session)
      counts = FitProtocol.read_counts(@session)
      assert_not_nil(passing_results.index("<td bgcolor=\"#cfffcf\">"), passing_results)
      assert_nil(passing_results.index("FailFixture"), "Shouldn't have second table in output")
      assert_not_nil(failing_results.index("<td bgcolor=\"#ffcfcf\">"), failing_results)
      check_counts(counts, 1, 1, 0, 0)
      assert_equal(1, @fit_server.exit_code)
    end
    
    def test_processing_two_documents
    	startSession do
    	  FitProtocol.write_size(0, @session)
    	  FitProtocol.write_document(passing_table, @session)
    	  FitProtocol.write_document(failing_table, @session)
    	  FitProtocol.write_size(0, @session)
    	end
      @fit_server.establish_connection()
      @fit_server.process()
      passing_results = FitProtocol.read_document(@session)
      FitProtocol.read_size(@session)
      passingCounts = FitProtocol.read_counts(@session)
      failing_results = FitProtocol.read_document(@session)
      FitProtocol.read_size(@session)
      failingCounts = FitProtocol.read_counts(@session)
      assert_not_nil(passing_results.index("<td bgcolor=\"#cfffcf\">"), passing_results)
      assert_not_nil(failing_results.index("<td bgcolor=\"#ffcfcf\">"), failing_results)
      check_counts(passingCounts, 1, 0, 0, 0)
      check_counts(failingCounts, 0, 1, 0, 0)
      assert_equal(1, @fit_server.exit_code)
    end
    
    def test_non_test_input
    	startSession do
    	  FitProtocol.write_size(0, @session)
    	  FitProtocol.write_document("Hey! There's no table here!'", @session)
    	  FitProtocol.write_size(0, @session)
    	end
      @fit_server.establish_connection()
      @fit_server.process()
      results = FitProtocol.read_document(@session)
      FitProtocol.read_size(@session)
      counts = FitProtocol.read_counts(@session)
      assert_not_nil(results.index("Exception"))
      assert_not_nil(results.index("Can't find tag: table"))
      check_counts(counts, 0, 0, 0, 1)
      assert_equal(1, @fit_server.exit_code)
    end
    
    def check_counts (counts, right, wrong, ignores, exceptions)
      assert_equal(right, counts.right, "rights wrong")
      assert_equal(wrong, counts.wrong, "wrongs wrong")
      assert_equal(ignores, counts.ignores, "ignores wrong")
      assert_equal(exceptions, counts.exceptions, "exceptions wrong")
    end
    
    def startSession (&connectionAction)
      @fit_server.args(['localhost', '9002', '123'])
      @server_thread = Thread.new do
        begin
          @server = TCPServer.new('localhost', 9002)
          @session = @server.accept
          request = @session.readline
          @session.readline
        rescue => e
          puts e
        end
        
        yield connectionAction
      end
      sleep(0.1)
    end
    
    def passing_table
      return "<table><tr><td>fixtures::PassFixture</td></tr></table>"
    end
    
    def failing_table
      return "<table><tr><td>fixtures::FailFixture</td></tr></table>"
    end
    
  end
end
