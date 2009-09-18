require 'fit/row_fixture'

module Eg
  module Book

    class DiscountGroupOrderedList < Fit::RowFixture
      def query
        groups = DiscountGroup.get_elements
        ordered_groups = []
        groups.each_with_index { |e, i|
          group = OrderedDiscountGroup.new(i + 1, e.future_value,
                                           e.max_owing, e.min_purchase, e.discount_percent)
          ordered_groups << group
        }
        ordered_groups
      end
      def get_target_class
        OrderedDiscountGroup
      end
    end

    # System under test

    class OrderedDiscountGroup
      attr_reader :order, :future_value
      attr_reader :max_owing, :min_purchase, :discount_percent
      def initialize order, future_value, max_owing, min_purchase, discount_percent
        @order = order
        @future_value = future_value
        @max_owing = max_owing
        @min_purchase = min_purchase
        @discount_percent = discount_percent
      end
      @@metadata = { 'order' => Fixnum, 'future_value' => String,
                     'max_owing' => Float, 'min_purchase' => Float, 'discount_percent' => Float }
      def OrderedDiscountGroup.metadata; @@metadata; end
    end

    class DiscountGroup
      attr_reader :future_value
      attr_reader :max_owing, :min_purchase, :discount_percent
      def initialize future_value, max_owing, min_purchase, discount_percent
        @future_value = future_value
        @max_owing = max_owing
        @min_purchase = min_purchase
        @discount_percent = discount_percent
      end
      def DiscountGroup.get_elements
        [ DiscountGroup.new('low', 0, 0, 0),
          DiscountGroup.new('low', 0, 2000, 3),
          DiscountGroup.new('medium', 500, 600, 3),
          DiscountGroup.new('medium', 0, 500, 5),
          DiscountGroup.new('high', 2000, 2000, 10)
        ]
      end
    end

  end
end
