#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

$:.unshift File.expand_path(File.dirname(__FILE__))
require 'erml_support'
require 'erml_widgets'

module EideticRML
  STANDARD_ALIASES = [
    { 'id' => 'h', 'tag' => 'p', 'font.weight' => 'Bold', 'text_align' => 'center' }.freeze,
    { 'id' => 'b', 'tag' => 'span', 'font.weight' => 'Bold' }.freeze,
    { 'id' => 'i', 'tag' => 'span', 'font.style' => 'Italic' }.freeze,
    { 'id' => 'u', 'tag' => 'span', 'underline' => 'true' }.freeze,
    { 'id' => 'hbox', 'tag' => 'div', 'layout' => 'hbox' }.freeze,
    { 'id' => 'vbox', 'tag' => 'div', 'layout' => 'vbox' }.freeze,
    { 'id' => 'table', 'tag' => 'div', 'layout' => 'table' }.freeze,
    { 'id' => 'layer', 'tag' => 'div', 'position' => 'relative', 'width' => '100%', 'height' => '100%' }.freeze,
    { 'id' => 'br', 'tag' => 'label' }.freeze
  ]

  class StyleBuilder
    def initialize(styles)
      @styles = styles
    end

    def method_missing(id, *args)
      @styles.add(id, *args)
    end
  end

  class RuleBuilder
    def initialize(rules)
      @rules = rules
    end

    def rule(selector, attrs={})
      @rules.add(selector, attrs)
    end
  end

  class PageBuilder
    undef_method :p

    def initialize(doc)
      @stack = [doc]
      @tag_aliases = {}
      EideticRML::STANDARD_ALIASES.each do |a|
        a = a.dup
        define(a.delete('id'), a['tag'], a)
      end
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
        attrs = attrs.merge(fix_attrs(args.first))
        attrs['tag'] = id unless tag == id
        factory = Widgets::StdWidgetFactory.instance # TODO: select factory by namespace
        raise ArgumentError, "Unknown tag: #{tag}." unless factory.has_widget?(tag)
        widget = factory.make_widget(tag, current, attrs)
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

    def define(new_tag, old_tag, attrs)
      @tag_aliases[new_tag.to_s] = [old_tag.to_s, attrs.clone.freeze]
    end

  private
    def current
      @stack.last
    end

    def fix_attrs(attrs)
      if attrs.nil?
        {}
      elsif attrs.respond_to?(:to_str)
        { :text => attrs }
      else
        attrs
      end
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

    def rules(&block)
      @rules ||= RuleBuilder.new(@doc.rules)
      @rules.instance_eval(&block)
    end

    def pages(attrs={}, &block)
      @doc.attributes(attrs)
      @pages ||= PageBuilder.new(@doc)
      @pages.instance_eval(&block) if block_given?
      @pages
    end

    def print(options={})
      file = options[:file] || "#{File.basename($0, '.rb')}.pdf"
      File.open(file,'w') { |f| f.write(@doc) }
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

  class XmlRuleParser
    undef_method :p
    undef_method :rule if self.private_methods.include?('rule')

    def initialize(stack, rules)
      @stack, @rules = stack, rules
      @stack.push rules
    end

    def comment(text)
      # puts "rule comment: #{text}"
      Rules::Rule.parse(text).each { |rule| @rules.add(rule[0], rule[1]) }
    end

    def method_missing(id, *args)
      @stack.push @rules.add(id, *args)
    end

    def text(text)
      # no meaningful text in rules section
    end
  end

  class XmlPageParser
    undef_method :p
    undef_method :method

    def initialize(stack, doc)
      @stack = stack
      @stack.push doc
      @tag_aliases = {}
      STANDARD_ALIASES.each { |definition| define(definition) }
    end

    def method_missing(id, *args)
      # puts "page method_missing: #{id}"
      if current.respond_to?(id)
        current.send(id, *args)
        @stack.push(current)
      else
        tag, attrs = @tag_aliases[id.to_s] || [id.to_s, {}]
        attrs = attrs.merge(args.first)
        attrs['tag'] = id unless tag == id
        factory = Widgets::StdWidgetFactory.instance # TODO: select factory by namespace
        raise ArgumentError, "Unknown tag: #{tag}." unless factory.has_widget?(tag)
        # puts "Making #{tag} with parent #{current.class}."
        widget = factory.make_widget(tag, current, attrs)
        @stack.push(widget)
      end
    end

    def define(attrs)
      attrs = attrs.dup
      id, tag = attrs.delete('id').to_s, attrs['tag'].to_s
      raise ArgumentError, "Invalid id for define: #{id}." unless id =~ /^(\w+)$/
      raise ArgumentError, "Invalid tag for define: #{tag}." unless tag =~ /^(\w+)$/
      @tag_aliases[id] = [tag, attrs.freeze]
      @stack.push(current)
    end

    def text(text)
      if current.respond_to?(:text)
        current.text(text)
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

    def comment(text)
      # puts "base comment: #{text}"
      @parser.comment(text) if @parser.respond_to?(:comment)
    end

    def tag_start(name, attrs)
      # puts "tag_start: #{name}"
      if @parser.nil?
        self.send(name, attrs)
      else
        @parser.send(name, attrs)
      end
    rescue Exception => e
      raise ArgumentError,
        "Error processing <%s>\n%s" % [attrs.inject(name) { |tag, (k, v)| tag << " #{k}=\"#{v}\"" }, e.message], e.backtrace
    end

    def tag_end(name)
      # puts "tag_end: #{name}"
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

    def rules(attrs)
      # puts "rules"
      @parser = XmlRuleParser.new(@stack, @doc.rules)
      if url = attrs['url']
        text = open(url) { |f| f.read }
        @parser.comment(text)
      end
    end

    def pages(attrs)
      # puts "pages"
      @doc.attributes(attrs)
      @parser = XmlPageParser.new(@stack, @doc)
    end
  end
end

def open_erml(erml, &block)
  if erml =~ /\.erb$/
    require 'erb'
    require 'stringio'
    source = open(erml) { |f| f.read }
    result = ERB.new(source).result
    sio = StringIO.new(result)
    yield(sio)
  elsif erml =~ /\.haml$/
    require 'haml'
    require 'stringio'
    source = open(erml) { |f| f.read }
    result = Haml::Engine.new(source).render
    sio = StringIO.new(result)
    yield(sio)
  else
    File.open(erml, &block)
  end
end

def render_erml(erml)
  doc = open_erml(erml) do |f|
    begin
      EideticRML::XmlParser.parse(f)
    rescue Exception => e
      $stderr.puts "Error in %s: %s\n%s" % [erml, e.message, e.backtrace.join("\n")]
    end
  end
  unless doc.nil?
    pdf = erml.sub(/\.erml(\.erb|\.haml)?$/, '') << '.pdf'
    File.open(pdf, 'w') { |f| f.write(doc) }
    return pdf
  end
end

# ARGV.unshift "samples/test24.erml.erb" unless ARGV.size.nonzero?
if $0 == __FILE__ and erml = ARGV.shift and File.exist?(erml)
  begin
    pdf = render_erml(erml)
    `open #{pdf}` if pdf and (RUBY_PLATFORM =~ /darwin/) and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
  rescue Exception => e
    $stderr.puts e.message, e.backtrace.join("\n")
  end
end
