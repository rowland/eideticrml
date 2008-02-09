#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

require 'erml_support'
require 'erml_widgets'

module EideticRML
  class StyleBuilder
    def initialize(styles)
      @styles = styles
    end

    def method_missing(id, *args)
      @styles.add(id, *args)
    end
  end

  class ClassBuilder
    def initialize
    end
  end

  class PageBuilder
    undef_method :p

    def initialize(doc)
      @stack = [doc]
      @tag_aliases = {}
    end

    def initialize_copy(other)
      @stack = @stack.clone
    end

    def method_missing(id, *args, &block)
      if current.respond_to?(id)
        current.send(id, *args)
        return current
      else
        tag, attrs = @tag_aliases[id.to_s] || [id.to_s, {}]
        factory = Widgets::StdWidgetFactory.instance # TODO: select factory by namespace
        raise ArgumentError, "Unknown tag: #{tag}." unless factory.has_widget?(tag)
        widget = factory.make_widget(tag, current, attrs.merge(args.first))
        @stack.push(widget)
        result = if block_given?
          yield
          current
        else
          self.clone
        end
        @stack.pop
        return result
      end
    end

    def tag_alias(new_tag, old_tag, attrs)
      @tag_aliases[new_tag.to_s] = [old_tag.to_s, attrs.clone.freeze]
    end

  private
    def current
      @stack.last
    end
  end

  class Builder
    attr_reader :doc

    def initialize(&block)
      @doc = Widgets::Document.new
      self.instance_eval(&block) if block_given?
    end

    def styles(&block)
      @styles ||= StyleBuilder.new(@doc.styles)
      @styles.instance_eval(&block) if block_given?
      @styles
    end

    def classes(&block)
      @classes ||= ClassBuilder.new
      @classes.instance_eval(&block)
    end

    def pages(attrs={}, &block)
      @pages ||= PageBuilder.new(@doc)
      @pages.instance_eval(&block) if block_given?
      @pages
    end

    def print(options={})
      file = options[:file] || "#{File.basename($0, '.rb')}.pdf"
      File.open(file,'w') { |f| f.write(@doc) }
    end

  private
    def attrs_from_hash(hash)
      attrs = ''
      return attrs if hash.nil?
      hash.each { |k, v| attrs << %Q{ %s="%s"} % [k, v] }
      attrs
    end
  end

  class XmlStyleParser
    undef_method :p

    def initialize(stack, styles)
      @stack, @styles = stack, styles
      @stack.push styles
    end

    def method_missing(id, *args)
      attrs = args.first.inject({}) { |attrs, kv| attrs[kv[0].to_sym] = kv[1]; attrs }
      @styles.add(id, attrs)
      @stack.push @styles
    end

    def text(text)
      # no meaningful text in styles section
    end
  end

  class XmlClassParser
    undef_method :p

    def initialize(stack, klasses)
      @stack, @klasses = stack, klasses
      @stack.push klasses
    end

    def method_missing(id, *args)
      # @klasses.add(id, *args)
      @stack.push @klasses
    end

    def text(text)
      # no meaningful text in classes section
    end
  end

  class XmlPageParser
    undef_method :p

    def initialize(stack, doc)
      @stack = stack
      @stack.push doc
      @tag_aliases = {}
    end

    def method_missing(id, *args)
      if current.respond_to?(id)
        current.send(id, *args)
        @stack.push(current)
      else
        tag, attrs = @tag_aliases[id.to_s] || [id.to_s, {}]
        factory = Widgets::StdWidgetFactory.instance # TODO: select factory by namespace
        raise ArgumentError, "Unknown tag: #{tag}." unless factory.has_widget?(tag)
        # puts "Making #{tag} with parent #{current.class}."
        widget = factory.make_widget(tag, current, attrs.merge(args.first))
        @stack.push(widget)
      end
    end

    def text(text)
      if current.respond_to?(:text)
        current.text(text.strip)
      end
    end

  private
    def current
      @stack.last
    end
  end

  class XmlParser
    attr_reader :doc

    def initialize
      @doc = Widgets::Document.new
    end

    def self.parse(data)
      require 'rexml/document'
      parser = self.new
      REXML::Document.parse_stream(data, parser)
      parser.doc
    end

    def tag_start(name, attrs)
      # puts "tag start: #{name}, #{attrs.inspect}"
      if @parser.nil?
        self.send(name, attrs)
      else
        @parser.send(name, attrs)
      end
    end

    def tag_end(name)
      # puts "tag end: #{name}"
      @stack.pop
      @parser = nil if @stack.empty?
    end

    def text(text)
      # puts "text: #{text.strip}"
      @parser.text(text) unless @parser.nil?
    end

    def method_missing(id, *args)
      # puts "missing: #{id}, #{args.inspect}"
    end

  private
    def current
      @stack.last
    end

    def erml(attrs)
      @stack = []
    end

    def styles(attrs)
      # puts "styles"
      @parser = XmlStyleParser.new(@stack, @doc.styles)
    end

    def classes(attrs)
      # puts "classes"
      @parser = XmlClassParser.new(@stack, nil)
    end

    def pages(attrs)
      # puts "pages"
      @parser = XmlPageParser.new(@stack, @doc)
    end
  end
end

if $0 == __FILE__ and erml = ARGV.shift and File.exist?(erml)
  pdf = ARGV.shift || "%s/%s.pdf" % [File.dirname(erml), File.basename(erml, '.erml')]
  doc = File.open(erml) do |f|
    EideticRML::XmlParser.parse(f)
  end
  File.open(pdf, 'w') { |f| f.write(doc) }
  `open #{pdf}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
end
