require 'eg/nested/bob'

module Eg
	module Nested
		class BobTheBuilderFixture < Bob
			def are_you_bob
				'nope'
			end
		end
	end
end