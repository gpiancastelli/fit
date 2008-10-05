require 'fit/column_fixture'

module Eg
	module Nested
		class Bob < Fit::ColumnFixture
			attr_accessor :last_name
			def full_name
				"Bob #{@last_name}"
			end
		end
	end
end
