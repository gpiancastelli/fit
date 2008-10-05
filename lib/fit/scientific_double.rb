# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

module Fit

  # Warning: not (yet) a general number usable in all calculations
  class ScientificDouble

    attr_accessor :precision
    
    def initialize value
      @value = Float(value)
      @precision = 0
    end

    def ScientificDouble.value_of s
      if s.downcase.index('infinity')
        new (1.0/0.0) # Infinity
      else
        result = new s.to_f
        result.precision = precision s
        result
      end
    end
    
    def ScientificDouble.precision s
      value = s.to_f
      bound = tweak(s.strip).to_f
      (bound - value).abs
    end

    def ScientificDouble.tweak s
      pos = s.downcase.index('e')
      unless pos.nil?
        return tweak(s[0..(pos - 1)]) + s[pos..-1]
      end
      unless s.index('.').nil?
        return s + "5"
      end
      return s + ".5"
    end

    def == obj
      sd = ScientificDouble.value_of obj.to_s
      self.<=>(sd) == 0
    end

    def <=> obj
      other = obj.to_f
      diff = @value - other

      # workaround the much more precise way of Ruby doing floats than Java
      return 0 if @precision.zero? and diff.abs < 1.0e-5

      precision = @precision > obj.precision ? @precision : obj.precision      
      return -1 if diff < -precision
      return 1 if diff > precision
      return 0 if @value.nan? and other.nan?
      return 1 if @value.nan?
      return -1 if other.nan?
      0
    end

    def nan?; @value.nan?; end # unused?
    def to_f; @value; end
    def to_s; @value.to_s; end

  end

end
