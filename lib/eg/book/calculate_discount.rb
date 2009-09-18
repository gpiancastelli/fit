require 'fit/column_fixture'

module Eg
  module Book

    class CalculateDiscount < Fit::ColumnFixture
      attr_writer :amount
      def initialize
        @application = Discount.new
      end
      def discount
        @application.get_discount @amount
      end
    end

    class Discount
      # A 5 percent discount is provided whenever the
      # total purchase is greater than $1,000
      def get_discount amount
        (amount >= 1000) ? (amount / 100.0) * 5 : 0.0
      end
    end

  end
end
