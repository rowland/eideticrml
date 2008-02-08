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
    def initialize(doc)
      @stack = [doc]
      @tag_aliases = {}
    end

    def initialize_copy(other)
      @stack = @stack.clone
    end

    undef_method :p

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
    attr_reader :file

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
      @file = options[:file] || "#{File.basename($0, '.rb')}.pdf"
      File.open(@file,'w') { |f| f.write(@doc) }
    end

  private
    def attrs_from_hash(hash)
      attrs = ''
      return attrs if hash.nil?
      hash.each { |k, v| attrs << %Q{ %s="%s"} % [k, v] }
      attrs
    end
  end
end
