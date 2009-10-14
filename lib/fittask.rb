require 'rake'
require 'rake/tasklib'

require 'fit/file_runner'
require 'fit/parse'

require 'stringio'

module Rake

  class FitReportRunner < Fit::FileRunner
    def run args, opts=nil
      @encoding = opts[:encoding].upcase unless opts.nil? 
      process_args args
      process
    end
  end
  
  class FitRunner < Fit::FileRunner
    def run args, opts=nil
      @encoding = opts[:encoding].upcase unless opts.nil? 
      process_args args
      process
    end
    def check_output_file arg; end
    def create_output_file output_name
      @output = StringIO.new
    end
  end

  # Create a task that runs a set of FIT tests.
  #
  # If rake is invoked with an ATEST command line option, then the list of
  # test files will be overridden to include only the filename specified on
  # the command line.  This provides an easy way to run just one test.
  # The exact syntax of the ATEST option is as follows:
  #    ATEST=/path/to/FileHtml:Right:Wrong:Ignores:Exceptions:Encoding
  # where you can include a path to the HTML file, which must be specified
  # without the .html extension; where Rights, Wrong, Ignores and Exceptions
  # are the numbers of the expected results from the test run; and where
  # Encoding is the character encoding of the input file. Note that the
  # report path will be the same as the test path.
  #
  class FitTask < TaskLib
  
    attr_accessor :name, :libs, :pattern, :fail_on_failed_test
    
    def test_suites=(list)
      @test_suites = list
    end
    
    def test_suites
      if ENV['ATEST']
        atest = ENV['ATEST'].split ':'
        filename = atest[0]
        test_name = File.basename(filename)
        test = { :name => test_name, :right => atest[1].to_i, :wrong => atest[2].to_i,
                 :ignores => atest[3].to_i, :exceptions => atest[4].to_i, :encoding => atest[5] }
        suite = AcceptanceTestSuite.new
        suite << test
        suite.test_path = suite.report_path = File.dirname(filename) + File::SEPARATOR
        [suite]
      else
        @test_suites
      end
    end
    
    def initialize(name=:fittest)
      @name = name
      @libs = ["lib"]
      @pattern = nil
      @test_files = []
      @test_suites = []
      @fail_on_failed_test=false
      @tests_failed=false
      yield self if block_given?
      define name
    end
    
    def define task_name
      # describe the fit task
      desc "Run FIT acceptance tests"
      task task_name
      # silence footnote creation since we don't want HTML reports
      task task_name do
        Fit::Parse.send(:define_method, 'footnote', lambda {''})
      end
      # define a fit task for each test suite
      test_suites.each do |suite|
        task task_name do
          @tests_failed = true unless suite.run_tests
        end
      end      

      task task_name do 
         raise 'Tests failed.' if @fail_on_failed_test && @tests_failed
      end

      # describe the fit_report task
      desc "Run FIT acceptance tests with HTML reports"
      task_report_name = (task_name.to_s + '_report').to_sym
      task task_report_name
      # define a fit_report task for each test suite
      test_suites.each do |suite|
        task task_report_name do
          # set footnote path to an appropriate location
          Fit::Parse.footnote_path = suite.report_path
          # run tests
          @tests_failed = true unless suite.run_tests_with_reports
        end
      end

      task task_report_name do 
        raise 'Tests failed.' if @fail_on_failed_test && @tests_failed
      end

      self
    end
    
    def create_test_suite &block
      suite = AcceptanceTestSuite.new
      block.call suite
      @test_suites << suite
    end
      
    class AcceptanceTestSuite
      attr_accessor :test_path, :report_path, :tests
      def initialize
        @tests = []
        @test_path = @report_path = ''
      end
      def << test
        @tests << test
      end

      def run_tests_with_reports; run_tests true; end;

      def run_tests with_report=false 
        all_passed = true
        @tests.each do |test|
          begin
            runner_args = [@test_path + "#{test[:name]}.html"]
            puts "Running #{test[:name]}.html"

            if with_report 
              report_file = @report_path + "Report_#{test[:name]}.html" 
              puts "   (Writing report to #{report_file})"
              runner_args << report_file
              runner = Rake::FitReportRunner.new
            else
              runner = Rake::FitRunner.new
            end

            opts = test[:encoding].nil? ? nil : {:encoding => test[:encoding]} 
            runner.run runner_args, opts
            result = runner.fixture.counts
            verify test, result
          rescue Exception => e
            puts "   #{test[:name]} failed: #{e}"
            all_passed = false
          end
        end
        all_passed
      end

      def verify test, result
        [:exceptions, :wrong].each { |symbol| test[symbol] = 0 if test[symbol].nil? }
        [:right, :wrong, :ignores, :exceptions].each do |symbol|
          count = result.method(symbol).call
          expected = test[symbol]
          unless expected.nil? || count == expected
            raise Exception.new("#{expected} #{symbol} expected, found #{count} instead.")
          end
        end
      end
    end
    
  end

end
