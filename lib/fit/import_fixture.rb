require 'fit/fixture'

module Fit
  class ImportFixture < Fixture
    def do_row row
     FixtureLoader.add_fixture_package row.parts.text.gsub('.','::') 	    
    end
  end
end
