# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/primitive_fixture'
require 'fit/scientific_double'
require 'fit/type_adapter'

require 'fat/money'

module Fat

  class Equals < Fit::PrimitiveFixture

    attr_accessor :heads, :adapter, :x, :y

    def do_rows rows
      @heads = rows.parts
      super rows.more
    end

    def do_cell cell, column_index
      begin
        head = @heads.at(column_index).text[0..0]
        case head
          when 't' then @adapter = type(cell.text)
          when 'x' then @x = @adapter.parse(cell.text)
          when 'y' then @y = @adapter.parse(cell.text)
          when '=' then check_boolean(cell, @adapter.equals(@x, @y))
          when '?' then cell.add_to_body(Fit::Fixture.gray("x: #{print(@x)} y: #{print(@y)}"))
          else raise "Don't do #{head}"
        end
      rescue Exception => e
        exception cell, e
      end
    end

    def type name;
      case name
        when 'date' then Fit::TypeAdapter.on(self, ParseDate)
        when 'integer' then Fit::TypeAdapter.on(self, Integer)
        when 'real' then Fit::TypeAdapter.on(self, Float)
        when 'scientific' then Fit::TypeAdapter.on(self, Fit::ScientificDouble)
        when 'money' then Fit::TypeAdapter.on(self, Money)
        else Fit::TypeAdapter.for(self, '', false)
      end
    end

    def parse string, klass
      return Money.new(string) if klass == Money
      return Float(string) if klass == Float
      return Integer(string) if klass == Integer
      super
    end

    def print value; @adapter.to_s value; end
    
  end

end
