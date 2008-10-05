# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/fixture'
require 'fit/type_adapter'

module Fit

  class ActionFixture < Fixture

    attr_reader :cells
    protected :cells
    @@actor = nil

    def ActionFixture.actor; @@actor; end
    def ActionFixture.actor= value
      @@actor = value
    end

    def do_cells cells
      @cells = cells
      begin
        send(cells.text)
      rescue Exception => e
        exception cells, e
      end
    end

    def start
      klass = find_class @cells.more.text # using reflection
      @@actor = klass.new
    end

    # ActionFixture.enter could be called with regular methods
    # featuring a single argument, or on setters methods of the
    # form 'name=' when an assignment on an attr is tried.
    def enter
      method_name = Fixture.camel @cells.more.text
      parameter = @cells.more.more.text
      adapter = TypeAdapter.for(@@actor, method_name, false)
      adapter.type = @@actor.class.metadata[method_name]
      argument = adapter.parse(parameter)
      m = @@actor.method method_name
      if m.arity == 1
        @@actor.send(method_name, argument)
      else
        adapter.set argument
      end
    end

    def press
      method_name = Fixture.camel @cells.more.text
      @@actor.send method_name
    end

    def check
      method_name = Fixture.camel @cells.more.text
      adapter = TypeAdapter.for(@@actor, method_name, false)
      adapter.type = @@actor.class.metadata[method_name]
      super(@cells.more.more, adapter)
    end

  end

end
