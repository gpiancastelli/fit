# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'test/unit'

# Make the test run location independent
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'fit/fixture_loader'
require 'fit/import_fixture'
require 'eg/division'
require 'eg/all_files'
require 'eg/nested/bob_the_builder_fixture'
require 'eg/music/browser'


class A; end
class AFixture < Fit::Fixture; end


module Fit
  class FixtureLoaderTest < Test::Unit::TestCase
    def setup
      @loader = FixtureLoader.new
    end
    def test_you_can_load_a_fixture
      assert_instance_of(Eg::Division, @loader.load('Eg.Division'))
    end
    def test_java_simple_fixture
      assert_instance_of(Eg::AllFiles, @loader.load('eg.AllFiles'))
    end
    def test_java_nested_fixture
      assert_instance_of(Eg::AllFiles::Expand, @loader.load('eg.AllFiles$Expand'))
    end
    def test_you_can_load_a_fixture_with_colons_rather_than_dots
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('Eg::Nested::BobTheBuilderFixture'))
    end
    class LookImNotInTheRightPlace < Fixture
    end
    def test_you_can_load_any_fixture_already_loaded_regardless_of_path
      assert_instance_of(Fit::FixtureLoaderTest::LookImNotInTheRightPlace,
                         @loader.load('Fit.FixtureLoaderTest.LookImNotInTheRightPlace'))
    end
    def test_you_can_add_fixture_packages
      FixtureLoader.add_fixture_package('Eg::Music')
      assert_instance_of(Eg::Music::Browser, @loader.load('Browser'))
    end 
    def test_it_finds_fixtures_in_the_fit_module
      assert_instance_of(Fit::ImportFixture, @loader.load('ImportFixture'))
    end
    def test_it_adds_fixture_to_the_end_if_it_cant_find_the_class
      assert_instance_of(Fit::ImportFixture, @loader.load('Import'))
    end
    def test_it_camelizes_separated_words
      FixtureLoader.add_fixture_package('Eg::Nested')
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob the builder fixture'))
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob the builder'))
    end
    def test_punctuation_separates_words
      FixtureLoader.add_fixture_package('Eg::Nested')
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob_the!-builder,fixture.'))
      assert_instance_of(Eg::Nested::BobTheBuilderFixture, @loader.load('bob_the!-builder.'))
    end
    def test_import_packages_are_unique
       FixtureLoader.add_fixture_package('Eg::Nested')
       FixtureLoader.add_fixture_package('Eg::Nested')
       assert_equal(1, FixtureLoader.fixture_packages.find_all { |e| e =~ /^Eg::Nested/}.size)
    end
    def test_it_raises_when_it_cant_find_the_fixture
      @loader.load "NoSuchClass"
    rescue StandardError => e
      assert_equal("Fixture NoSuchClass not found.", e.to_s)
    end
    def test_it_only_loads_fixtures
      @loader.load "String"
      flunk("Should have thrown.")
    rescue StandardError => e
      assert_equal("String is not a fixture.", e.to_s)
    end
    def test_loading_fixture_when_fixture_name_is_same_as_another_class_name
      assert_instance_of(AFixture, @loader.load('A'))
    end
  end
end
