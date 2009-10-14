require 'rake/clean'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'fittask'

desc "Run Fit TaskLib"
Rake::FitTask.new(:fit) do |t|
  # t.libs = ["lib/fit/*.rb"] # the fixture directory goes here

  t.fail_on_failed_test = true
  t.create_test_suite do |suite|
    suite.test_path = 'doc/fitnesse/'
    suite.report_path = 'doc/fitnesse/reports/'
    test_files = Dir.glob(suite.test_path + '/*.html')
    suite.tests = test_files.collect do |test_file| 
       { :name => File.basename(test_file, '.html') } 
    end
  end

  examples = []
  examples << { :name => 'arithmetic',
                :right => 39, :wrong => 8, :ignores => 0, :exceptions => 2 }
  examples << { :name => 'BinaryChop',
                :right => 95, :wrong => 0, :ignores => 0, :exceptions => 0 }
  examples << { :name => 'CalculatorExample',
                :right => 75, :wrong => 9, :ignores => 0, :exceptions => 0 }
  examples << { :name => 'MusicExample',
                :right => 95, :wrong => 0, :ignores => 0, :exceptions => 0 }
  examples << { :name => 'MusicExampleWithErrors',
                :right => 54, :wrong => 10, :ignores => 0, :exceptions => 0 }
  # WebPageExample is not here because it needs an active Internet connection
  examples << { :name => 'NetworkExample',
                :right => 5, :wrong => 0, :ignores => 0, :exceptions => 0 }
  examples << { :name => 'ColumnIndex',
                :right => 51, :wrong => 3, :ignores => 8, :exceptions => 0 }
  examples << { :name => 'AllFiles',
                :right => 9, :wrong => 3, :ignores => 0, :exceptions => 0 }
  examples << { :name => 'AllCombinations',
                :right => 72, :wrong => 14, :ignores => 0, :exceptions => 0 }
  examples << { :name => 'AllPairs',
                :right => 39, :wrong => 9, :ignores => 0, :exceptions => 0 }
  # Running the ExampleTests.html file is roughly equivalent to this test suite
  t.create_test_suite do |suite|
    suite.test_path = "doc/examples/"
    suite.report_path = "doc/reports/"
    suite.tests = examples
  end
  
  t.test_suites.each do |suite|
    CLOBBER.include(suite.report_path + "Report_*.html")
    CLOBBER.include(suite.report_path + "footnotes/")
  end
  
end

# desc 'Run tests from the book "Fit for developing software" by R.Mugridge & W.Cunningham'
Rake::FitTask.new(:fitbook) do |t|
  # Examples from the book "Fit for developing software" by R.Mugridge & W.Cunningham
  t.create_test_suite do |suite|
    tests = []
    tests << { :name => 'TestDiscount',
               :right => 7, :wrong => 1, :ignores => 0, :exceptions => 0 }
    tests << { :name => 'TestDiscountMoney',
               :right => 7, :wrong => 1, :ignores => 0, :exceptions => 0 }
    tests << { :name => 'TestChatServer' }
    tests << { :name => 'TestDiscountGroup' }
    tests << { :name => 'TestLateHours' }
    suite.test_path = "doc/book/"
    suite.report_path = "doc/book/"
    suite.tests = tests

    CLOBBER.include(suite.report_path + "Report_*.html")
    CLOBBER.include(suite.report_path + "footnotes/")
  end
end

Rake::FitTask.new(:fitbugs) do |t|
  t.create_test_suite do |suite|
    suite.test_path = "doc/bugs/"
    suite.report_path = "doc/bugs/"
    suite << { :name => 'ColumnFixtureFollowedByActionFixture',
               :right => 8, :wrong => 1, :ignores => 0, :exceptions => 0 }
  end
end

Rake::FitTask.new(:fitspec) do |t|
  t.create_test_suite do |suite|
    suite.test_path = "doc/spec/"
    suite.report_path = "doc/spec/"
    suite << { :name => 'parse',
               :right => 83, :wrong => 0, :ignores => 0, :exceptions => 0 }
    suite << { :name => 'annotation',
               :right => 47, :wrong => 0, :ignores => 0, :exceptions => 0 }
    suite << { :name => 'ui',
               :right => 30, :wrong => 0, :ignores => 0, :exceptions => 0 }
  end
end

require 'rake/testtask'

desc "Default task is to run FIT unit tests."
task :default => :test

desc "Run FIT unit tests."
Rake::TestTask.new do |t|
  t.test_files = FileList['test/all_tests.rb']
  t.verbose = true
  t.libs = ['lib','test'] # verify why is needed
end

### RubyGems related stuff

require 'rake/gempackagetask'

require 'fit/version'

spec = Gem::Specification.new do |s|
  s.name = 'fit'
  s.version = Fit::VERSION
  s.author = 'Giulio Piancastelli'
  # See the README for other authors/developers/contributors
  s.email = 'giulio.piancastelli@gmail.com'
  s.homepage = 'http://fit.rubyforge.org/'
  s.rubyforge_project = 'fit'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A Ruby port of FIT (Framework for Integrated Testing)'
  s.description = <<EOF_DESCRIPTION
RubyFIT is a tool for enhancing communication and collaboration in
software development. It allows customers, testers, and programmers
to learn what their software should do and what it does do, by
automatically comparing customers' expectations to actual results.
EOF_DESCRIPTION
  s.files = FileList["{bin,lib,test,doc}/**/*"].to_a + ["Rakefile", "CHANGELOG"]
  s.require_path = 'lib'
  # s.autorequire something?
  # set for executable scripts in the bin/ subdirectory
  s.bindir = 'bin'
  s.executables << 'fit'
  s.test_file = 'test/all_tests.rb'
  s.has_rdoc = false # no RDoc comments in the code
  s.extra_rdoc_files = ["README.rdoc"]
  # no external dependencies on other gems
end

# Cygwin's ln fails under my Windows installation
FileUtils::LN_SUPPORTED[0] = false

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end