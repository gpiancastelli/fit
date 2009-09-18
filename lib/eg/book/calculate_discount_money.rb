require 'fit/column_fixture'

module Eg
  module Book

    class MoneyDiscount
      # A 5 percent discount is provided whenever the
      # total purchase is greater than $1,000
      def get_discount amount
        (amount >= Money.new(1000)) ? (amount * 0.05) : Money.new
      end
    end

    class Money
      attr_reader :cents
      def initialize amount = 0
        @cents = (amount * 100 + 0.5).to_i
      end
      def >= money
        @cents >= money.cents
      end
      def * times
        Money.new(@cents / 100.0 * times)
      end
      def == money
        money.class == Money and @cents == money.cents
      end
      def Money.parse string
        raise Exception.new('Invalid money value') unless string =~ /^\$/
        dot = string.index '.'
        raise Exception.new('Invalid money value') if dot.nil? or dot != string.size - 3
        money = string[1..-1].to_f
        Money.new money
      end
      def to_s
        cent_string = "#{@cents % 100}"
        cent_string += '0' if cent_string.size == 1
        "$#{cents / 100}.#{cent_string}"
      end
    end

    # Fixture

    class CalculateDiscountMoney < Fit::ColumnFixture
      attr_writer :amount
      def initialize
        @application = MoneyDiscount.new
      end
      def discount
        @application.get_discount @amount
      end
      @@metadata = { 'amount' => Money, 'discount()' => Money }
      def parse string, klass
        return Money.parse(string) if klass == Money
        super
      end
    end

  end
end
