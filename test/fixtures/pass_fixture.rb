require 'fit/fixture'

module Fixtures
  class PassFixture < Fit::Fixture
    def do_table(table)
      right(table.parts.parts)
    end
  end
end
