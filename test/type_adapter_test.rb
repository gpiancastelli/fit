# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'
# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'fit/type_adapter'
require 'fit/column_fixture' # for a dummy fixture

module Fit

  # A dummy fixture used by tests for TypeAdapter
  class TestFixture < ColumnFixture
    attr_accessor :sample_integer, :sample_float, :sample_string
    attr_accessor :sample_array, :sample_boolean # missing sample_date
    attr_accessor :sample_with_2_digits1
    def might_end_in_qm
       false
    end
    def might_end_in_qm?
       true
    end
    def pi
      3.14159265
    end
  end

  class TypeAdapterTest < Test::Unit::TestCase
    def setup
      @f = TestFixture.new
    end
    def test_it_can_figure_out_direction
       adapter = TypeAdapter.for @f, 'sample_integer'
       adapter.set(adapter.parse('123456'))
       assert_equal 123456, @f.sample_integer

       adapter = TypeAdapter.for @f, 'sample_integer?'
       assert_raises(RuntimeError) { adapter.set(adapter.parse('789')) }       
       assert_equal 123456, @f.sample_integer

       adapter = TypeAdapter.for @f, 'sample_integer()'
       assert_raises(RuntimeError) { adapter.set(adapter.parse('789')) }       
       assert_equal 123456, @f.sample_integer
    end
    def test_integer
      adapter = TypeAdapter.for @f, 'sample_integer', false
      adapter.set(adapter.parse('123456'))
      assert_equal 123456, @f.sample_integer
    end
    def test_negative_integer
      adapter = TypeAdapter.for @f, 'sample_integer', false
      assert_equal '-234567', adapter.parse('-234567').to_s
    end
    def test_method
      adapter = TypeAdapter.for @f, 'pi', true
      assert_in_delta 3.14159, adapter.get, 0.00001
      assert_equal 3.14159265, adapter.get
    end
    def test_string
      adapter = TypeAdapter.for @f, 'sample_string', false
      adapter.set(adapter.parse('xyzzy'))
      assert_equal 'xyzzy', @f.sample_string
    end
    def test_double
      adapter = TypeAdapter.for @f, 'sample_float', false
      adapter.set(adapter.parse('6.02e23'))
      assert_in_delta 6.02e23, @f.sample_float, 1e17
    end
    def test_array
      adapter = TypeAdapter.for @f, 'sample_array', false
      adapter.set(adapter.parse('1, 2, 3'))
      assert_equal 1, @f.sample_array[0]
      assert_equal 2, @f.sample_array[1]
      assert_equal 3, @f.sample_array[2]
      assert_equal '1, 2, 3', adapter.to_s(@f.sample_array)
      assert_equal [1,2,3], @f.sample_array
    end
    def test_boolean
      verify_sample_boolean_adapter_setter @f, 'sample_boolean'
    end
    def verify_sample_boolean_adapter_setter(fixture,method)
       adapter = TypeAdapter.for fixture, method, false
       adapter.set(adapter.parse('true'))
       assert fixture.sample_boolean
       adapter.set(adapter.parse('false'))
       assert !fixture.sample_boolean
    end
      def test_digits_in_the_name
         adapter = TypeAdapter.for @f, "sample_with_2_digits1", false
         adapter.set(adapter.parse('true'))
         assert @f.sample_with_2_digits1
         adapter.set(adapter.parse('false'))
         assert !@f.sample_with_2_digits1
      end
      def test_graceful_names_setters
         ['SampleBoolean','Sample Boolean','sample boolean','sample? boolean','sample, boolean','sample, boolean?'].each do |name|
            verify_sample_boolean_adapter_setter @f, name
         end
      end
      def test_graceful_names_getters
         ['sample boolean()','sample_boolean()','Sample Boolean()','SampleBoolean()',
         'sample boolean?','sample_boolean?','Sample Boolean?','SampleBoolean?','Sample.boolean'].each do |name|
            adapter=TypeAdapter.for @f, name
            [true,false].each { |v| @f.sample_boolean=v; assert_equal(v,adapter.get) }
         end
      end
      def test_getters_ending_with_question_mark
         # when the request ends in ?, prefer a method ending in ?
         adapter = TypeAdapter.for @f, "might_end_in_qm?"
         assert adapter.get
         # when the request doesn't end in ?, require a method not ending with ?
         adapter = TypeAdapter.for @f, "might_end_in_qm"
         assert ! adapter.get
         # when the request ends in ? accept a method not ending in ?, if one ending in ? is not present
         @f.sample_string='no qm'
         adapter = TypeAdapter.for @f, "sample_string?"
         assert_equal 'no qm',adapter.get
      end
  end
end
