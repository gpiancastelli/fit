# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/scientific_double'

module Fit

  class TypeAdapter

    attr_accessor :target, :type, :fixture

    def initialize target, name = '', is_output = false
      @is_output = is_output
      @target = @fixture = target
      
      @name=name
      ends_in_qm = is_output && name=~/\?$/
      if @name.index(/[A-Z]/)
        @name = @name.split(/([A-Z][^A-Z]+)/).delete_if {|e| e.empty?}.collect {|e| e.downcase}.join('_')
      end
      @name = @name.gsub(/[^0-9a-zA-Z_]+$/,'').gsub(/[^0-9a-zA-Z_]+/,'_').gsub(/_+/,'_')
      @name << '?' if ends_in_qm
    end

    # Factories

    def TypeAdapter.for fixture, name, is_output=(name=~/(\(\))|(\?)$/)
      GenericAdapter.new fixture, name, is_output
    end

    def TypeAdapter.on fixture, type
      adapter = GenericAdapter.new fixture
      adapter.type = type
      adapter
    end

    def get
      return nil if @name.nil?
      getter = @name
      getter.chop! if getter =~ /\?$/ && ! @target.respond_to?(getter.to_sym)
      @target.send(getter)
    end

    def set value
      raise 'Output fields cannot be set' if @is_output
      @target.send("#{@name}=", value)
    end

    def is_output?
      @is_output
    end

    def equals a, b
      if ((a.kind_of? Float) and (b.kind_of? Numeric)) or ((a.kind_of? Numeric) and (b.kind_of? Float))
        (a - b).abs < 1.0e-5 # use a delta to test equality between a float and a number
      else
        a == b
      end
    end

    def to_s target
      case target
      when Array
        target.join(", ")
      else
        target.to_s
      end
    end

  end

  # A generic adapter uses the appartent type of its input to store
  # appropriate values. For example, if a cell contains <td>1</td>,
  # a Fixnum is generated; if a cell contains <td>0.5</td>, a Float
  # is generated. Note that this process might not feasible for every
  # type of primitive data.
  class GenericAdapter < TypeAdapter
    def parse value
      return true if value.downcase == 'true'
      return false if value.downcase == 'false'
      unless @type.nil?
        result = @fixture.parse value, @type
        return result unless result.nil?
      end
      return Integer(value) if value =~ /^-?\d+$/
      return Float(value) if (value =~ /^-?\d*\.\d*$/ || value =~ /^-?\d*\.\d*[e|E]\d+$/)
      elements = value.split(',')
      unless elements.size == 1
        array = []
        element_adapter = TypeAdapter.for @target, @name, @is_output
        elements.each do |e|
          array << element_adapter.parse(e.strip)
        end
        return array
      end
      return value
    end
  end

end
