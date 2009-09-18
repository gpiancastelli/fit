require 'fit/column_fixture'

module Eg
  module Book

    module Rent
      class CalculateLateHours < Fit::ColumnFixture
        attr_writer :hours_late, :grace, :high_demand
        attr_writer :count_grace
        def count_grace= string
          @count_grace = { 'yes' => true, 'no' => false }[string]
        end
        def extra_hours
          late_returns = LateReturns.new @count_grace
          late_returns.extra_hours @hours_late, @grace, @high_demand
        end
      end
    end

    # System under test

    class LateReturns
      def initialize count_grace
        @count_grace = count_grace
      end
      def extra_hours hours_late, grace, high_demand
       return 0 if hours_late < 1
       hours = @count_grace ? hours_late : (hours_late - grace)
       return 0 if hours.zero?
       high_demand + hours
      end
    end

  end
end
