# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'eg/all_combinations'
require 'set'

module Eg

  class AllPairs < AllCombinations
    
    attr_accessor :steps, :to_item, :vars, :pairs
    @@rank = 0
    def AllPairs.rank; @@rank; end
    
    def initialize
      super
      @steps = 0
      @to_item = {}
      @vars = []
      @pairs = Set.new
    end
    
    protected
    
    def combinations
      populate
      generate
    end

    # Populate

    def populate
      do_all_vars
      do_all_var_pairs
    end

    def do_all_vars
      @@rank = 0
      @lists.each_with_index do |files, i|
        var = Var.new i, files
        @vars << var
        do_all_items var, files
      end
    end

    def do_all_items var, files
      files.each_with_index do |file, i|
        item = Item.new var, i, @@rank
        @@rank += 1
        @to_item[file] = item
        var.items << item
      end
    end

    def do_all_var_pairs
      @vars.each_with_index do |var, i|
        j = i + 1
        while j < @vars.size
          do_all_item_pairs @vars[i], @vars[j]
          j += 1
        end
      end
    end

    def do_all_item_pairs vl, vr
      vl.items.each do |var_left|
        vr.items.each do |var_right|
          @pairs << Pair.new(var_left, var_right)
        end
      end
    end

    # Generate

    def generate
      while @pairs.sort.first.used.zero?
        emit next_case
      end
    end

    def next_case
      slug = [nil] * @vars.size
      while not is_full?(slug)
        p = next_fit slug
        fill slug, p
      end
      slug
    end
    private :next_case

    def fill slug, pair
      slug[pair.left.var.index] = pair.left
      slug[pair.right.var.index] = pair.right
      pair.used += 1
      @pairs << pair
    end

    def is_full? slug
      slug.each {|s| return false if s.nil?}
      true
    end

    def next_fit slug
      hold = []
      pair = next_pair
      while not pair.is_fit?(slug)
        hold << pair
        pair = next_pair
      end
      @pairs += hold
      pair
    end

    def next_pair
      first = @pairs.sort.first
      @pairs.delete first
      @steps += 1
      first
    end

    def emit slug
      combination = []
      slug.each {|s| combination << s.file}
      do_case combination
    end

    # Helper classes

    class Var
      attr_accessor :files, :items
      attr_accessor :index
      def initialize index, files
        @index, @files = index, files
        @items = []
      end
    end

    class Item
      attr_accessor :var
      attr_accessor :index, :rank
      def initialize v, i, n
        @var, @index, @rank = v, i, n
      end
      def file; var.files[@index]; end
      def is_fit? slug
        slug[var.index].nil? or slug[var.index] == self
      end
    end

    class Pair
      attr_accessor :left, :right
      attr_accessor :used
      def initialize left, right
        @left, @right = left, right
        @used = 0
      end
      def is_fit? slug
        @left.is_fit?(slug) and @right.is_fit?(slug)
      end
      def rank
        AllPairs.rank * (AllPairs.rank * @used + @left.rank) + @right.rank
      end
      def <=> obj
        rank - obj.rank
      end
    end

    # No self test classes.

  end

end
