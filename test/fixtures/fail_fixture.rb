require 'fit/fixture'

module Fixtures
  class FailFixture < Fit::Fixture
    def do_table(table)
      wrong(table.parts.parts)
    end
  end
end