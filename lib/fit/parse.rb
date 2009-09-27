# Copyright (c) 2002 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.

require 'fileutils' # for footnotes generation

module Fit

  class ParseException < Exception
    attr_reader :error_offset
    def initialize message, offset
      super message
      @error_offset = offset
    end
  end

  # This ParseHolder class is necessary to cope with the different constructors
  # in the Java version of FIT. One of them is the constructor for the Parse Ruby
  # class, the other is a static method in the ParseHolder class.
  #
  # ParseHolder also maintain all the methods belonging to Parse which are instead
  # called whenever in FIT a ParseHolder is created instead of a Parse.
  class ParseHolder

    attr_accessor :leader, :tag, :body, :end, :trailer
    attr_accessor :more, :parts

    def ParseHolder.create tag, body, parts, more
      p = new
      p.leader = "\n"
      p.tag = "<#{tag}>"
      p.body = body
      p.end = "</#{tag}>"
      p.trailer = ""
      p.parts = parts
      p.more = more
      p
    end

    def leaf
      @parts.nil? ? self : @parts.leaf
    end

    def add_to_tag text
      @tag = @tag[0..-2] + "#{text}>"
    end

    def add_to_body text
      @body += text
    end
    
    def at i, *rest
      node = (i == 0 || @more.nil?) ? self : @more.at(i - 1)
      rest.each do |j|
        node = node.parts.at(j)
      end
      node
    end

    def text
      Parse.html_to_text @body
    end

    def last
      @more.nil? ? self : @more.last
    end

    def size
      @more.nil? ? 1 : @more.size + 1
    end

    def print out
      out.print @leader
      out.print @tag
      if @parts
        @parts.print out
      else
        out.print @body
      end
      out.print @end
      if @more
        @more.print out
      else
        out.print @trailer
      end
    end

  end

  class Parse < ParseHolder

    MAX_INT = 2147483647 # hardcoded java.lang.Integer.MAX_VALUE
    DEFAULT_TAGS = ['table', 'tr', 'td']

    @@footnote_files = 0

    def initialize text, tags = DEFAULT_TAGS, level = 0, offset = 0
      tag = tags[level]
      lc = text.downcase
      start_tag = lc.index "<#{tag}"
      raise ParseException.new("Can't find tag: #{tag}", offset) if start_tag.nil?
      end_tag = lc.index('>', start_tag)
      raise ParseException.new("Can't find tag: #{tag}", offset) if end_tag.nil?
      end_tag += 1
      start_end = find_matching_end_tag lc, end_tag, tag, offset
      raise ParseException.new("Can't find tag: #{tag}", offset) if start_end.nil?
      end_end = lc.index('>', start_end)
      raise ParseException.new("Can't find tag: #{tag}", offset) if end_end.nil?
      end_end += 1
      start_more = lc.index "<#{tag}", end_end
      
      @leader = text[0...start_tag]
      @tag = text[start_tag...end_tag]
      @body = text[end_tag...start_end]
      @end = text[start_end...end_end]
      @trailer = text[end_end..-1]

      if level + 1 < tags.size
        @parts = Parse.new @body, tags, level + 1, offset + end_tag
        @body = nil
      else # check for nested table
        index = @body.index "<#{tags[0]}"
        unless index.nil?
          @parts = Parse.new @body, tags, 0, offset + end_tag
          @body = ''
        end
      end

      unless start_more.nil?
        @more = Parse.new @trailer, tags, level, offset + end_end
        @trailer = nil
      end
    end

    def find_matching_end_tag lc, match_from_here, tag, offset
      from_here = match_from_here
      count = 1
      start_end = 0
      while count > 0
        embedded_tag = lc.index "<#{tag}", from_here
        embedded_tag_end = lc.index "</#{tag}", from_here
        # which one is closer?
        raise ParseException.new("Can't find tag: #{tag}", offset) if embedded_tag.nil? and embedded_tag_end.nil?
        embedded_tag = MAX_INT if embedded_tag.nil?
        embedded_tag_end = MAX_INT if embedded_tag_end.nil?
        if embedded_tag < embedded_tag_end
          count += 1
          start_end = embedded_tag
          from_here = lc.index('>', embedded_tag) + 1
        elsif embedded_tag_end < embedded_tag
          count -= 1
          start_end = embedded_tag_end
          from_here = lc.index('>', embedded_tag_end) + 1
        end
      end
      start_end
    end

    def Parse.html_to_text s
      str = s.gsub(%r{<\s*br\s*/?\s*>}, '<br />').gsub(%r{<\s*/\s*p\s*>\s*<\s*p( .*?)?\s*>}, '<br />')
      unescape(condense_whitespace(remove_tags(str)))
    end

    def Parse.remove_tags s
      s.gsub(/<.*?>/m) { $& == '<br />' ? $& : '' }
    end

    def Parse.unescape s
      str = Parse.unescape_numeric_entities s
      str = str.gsub %r{<br />}, "\n"
      # unescape HTML entities
      str = str.gsub(%r{&lt;}, '<').gsub(%r{&gt;}, '>').gsub(%r{&nbsp;}, ' ').gsub(%r{&quot;}, '"').gsub(%r{&amp;}, '&')
      # unescape smart quotes
      str.gsub(/\223/, '"').gsub(/\224/, '"').gsub(/\221/, "'").gsub(/\222/, "'")
    end

    def Parse.unescape_numeric_entities s
      result = ''
      last_start = 0
      starts_at = s.index '&#'
      while not starts_at.nil?
        ends_at = s.index ';', starts_at
        if ends_at.nil?
          starts_at = s.index('&#', starts_at + 1)
          next
        end
        begin
          entity = s[(starts_at + 2)...ends_at]
          entity = '0x' + entity[1..-1] if (entity =~ /^x/ or entity =~ /^X/)
          char = Integer(entity)
          #char = (entity =~ /^x/ or entity =~ /^X/) ? entity[1..-1].to_i(16) : entity.to_i
          if char <= 0xFFFF
            result += s[last_start...starts_at] + [char].pack('U')
            last_start = ends_at + 1
          end
        rescue ArgumentError
          # just loop around again
        ensure
          starts_at = s.index '&#', ends_at
        end
      end
      result += s[last_start..-1]
    end

    def Parse.condense_whitespace s
      # NOT_BREAKING_SPACE is decimal character 160, hex a0, oct 240
      s.gsub(%r{\s+}, ' ').gsub(/\240/, ' ').gsub(%r{&nbsp;}, ' ').strip
    end

    # The original implementation of footnote hardcodes the creation path,
    # hence is somewhat broken. The use of a class variable lets external
    # clients (like Rake and FitTask) decide where to generate footnotes.
    @@footnote_path = 'Reports/'
    def Parse.footnote_path=(path); @@footnote_path = path; end
    def Parse.footnote_path; @@footnote_path; end
    def footnote
      return '[-]' if @@footnote_files >= 25
      begin
        this_footnote = (@@footnote_files += 1)
        html = "footnotes/#{this_footnote}.html"
        path = "#{@@footnote_path}#{html}"
        FileUtils.mkpath File.dirname(path)
        f = File.new(path, 'w')
        print f
        f.close
        return "<a href=#{@@footnote_path}/#{html}>[#{this_footnote}]</a>"
      rescue Exception => e
        puts e.message
        puts e.backtrace
        return '[!]'
      end
    end

  end

end
