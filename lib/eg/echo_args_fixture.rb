require 'fit/row_fixture'

module Eg
  class EchoArgsFixture < Fit::RowFixture
    def query
      @args
    end
  end
end
