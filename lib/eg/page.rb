# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fit/parse'
require 'fit/row_fixture'

require 'open-uri'
require 'uri'

module Eg

  class Page < Fit::RowFixture

    @@url = nil
    @@text = ''

    # Actions

    def location url
      @@url = URI.parse url
      @@text = open(@@url) {|stream| stream.read}
    end

    def title
      Fit::Parse.new(@@text, ['title']).text
    end

    def link label
      links = Fit::Parse.new @@text, ['a']
      until links.text =~ /^#{label}/
        links = links.more
      end
      links.tag =~ /href\s*=\s*"(.*)"\s*>?/i
      if $1.nil?
        links.tag =~ /href\s*=\s*(.*)\s*>/i
      end
      link = $1
      if link =~ /^(http:)?\/\//
        @@url = URI.parse($1.nil? ? "http:#{link}" : link)
      else
        @@url = URI.parse(context(@@url) + link)
      end
      @@text = open(@@url) {|stream| stream.read}
    end

    def context url
      u = "#{url.scheme}://#{url.host}"
      u += (url.port == 80 ? '' : ":#{url.port}") + '/'
      u
    end

    # Rows

    def query
      tags = ['wiki', 'table', 'tr', 'td']
      rows = Fit::Parse.new(@@text, tags).at(0, 0, 2)
      result = [nil] * rows.size
      0.upto(rows.size - 1) do |i|
        result[i] = Row.new rows
        rows = rows.more
      end
      result
    end

    # Utility

    def get url
      response = Net::HTTP.get_response url
      response.body
    end

    class Row
      attr_accessor :cells
      def initialize row
        @cells = row.parts
      end
      def numerator; to_number(@cells.at(0).text); end
      def denominator; to_number(@cells.at(1).text); end
      # An hack to get the right type of number
      def to_number string
        begin
          return Integer(string)
        rescue
          return Float(string)
        end
      end
    end

  end

end
