# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'

module Fat

  class ReferenceFixture < Fit::ColumnFixture
    attr_accessor :description, :location
    def result
      input_name = "spec/#@location"
      output_name = "spec/results_#@location"
      begin
        runner = Fit::FileRunner.new
        runner.process_args [input_name, output_name]
        runner.process
        runner.output.close
        
        counts = runner.fixture.counts
        if counts.total_errors.zero?
          return 'pass'
        else
          return "fail: #{counts.to_s}"
        end
      rescue Exception => e
        return "file not found: #{input_name}"
      end
    end
  end

end
