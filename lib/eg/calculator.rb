# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/column_fixture'
require 'fit/scientific_double'

module Eg

  class Hp35
    attr_reader :r
    def initialize
      @r = [0, 0, 0, 0]
      @s = 0
    end
    def key key
      if key.kind_of? Numeric
        push key.to_f
      else
        case key
          when 'enter' then push
          when '+' then push(pop() + pop())
          when '-' then n = pop(); push(pop() - n)
          when '*' then push(pop() * pop())
          when '/' then n = pop(); push(pop() / n)
          when 'x^y' then push(pop() ** pop())
          when 'clx' then @r[0] = 0
          when 'clr' then @r[0] = @r[1] = @r[2] = @r[3] = 0
          when 'chs' then @r[0] = -@r[0]
          when 'x<>y' then @r[0], @r[1] = @r[1], @r[0]
          when 'r!' then @r[3] = pop()
          when 'sto' then @s = @r[0]
          when 'rcl' then push(@s)
          when 'sqrt' then push(Math.sqrt(pop()))
          when 'ln' then push(Math.log(pop()))
          when 'sin' then push(Math.sin(pop() / 180 * Math::PI))
          when 'cos' then push(Math.cos(pop() / 180 * Math::PI))
          when 'tan' then push(Math.tan(pop() / 180 * Math::PI))
          else raise "Can't do key: #{key}"
        end
      end
    end
    def push value = nil
      3.downto(1) {|i| @r[i] = @r[i - 1]}
      @r[0] = value unless value.nil?
    end
    def pop
      result = @r[0]
      0.upto(2) {|i| @r[i] = @r[i + 1]}
      result
    end
  end

  class Calculator < Fit::ColumnFixture
    attr_accessor :volts, :key
    @@metadata = { 'x()' => Fit::ScientificDouble, 'y()' => Fit::ScientificDouble,
                   'z()' => Fit::ScientificDouble, 't()' => Fit::ScientificDouble }
    @@hp = Hp35.new
    def points; false; end
    def flash; false; end
    def watts; 0.5; end
    def reset; key = nil; end
    def execute; @@hp.key(key) unless key.nil?; end
    def x; Fit::ScientificDouble.new @@hp.r[0]; end
    def y; Fit::ScientificDouble.new @@hp.r[1]; end
    def z; Fit::ScientificDouble.new @@hp.r[2]; end
    def t; Fit::ScientificDouble.new @@hp.r[3]; end
  end

end
