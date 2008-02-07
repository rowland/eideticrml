#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

require 'erml_support'
require 'erml_styles'
require 'singleton'
require 'erml_widget_factories'

module EideticRML
  module Widgets
    class StdWidgetFactory < WidgetFactory
      include Singleton

      WidgetFactory.register_factory('std', self.instance)
    end

    class Widget
      include Support

      attr_reader :parent, :width_pct, :height_pct, :width_rel, :height_rel

      def initialize(parent, attrs={})
        @parent = parent
        parent.children << self if parent.respond_to?(:children)
        attrs = attrs.inject({}) { |m, kv| m[kv.first.to_s] = kv.last; m }
        pre_keys, post_keys = attrs.keys & attributes_first, attrs.keys & attributes_last
        keys = attrs.keys - pre_keys - post_keys
        pre_keys.each { |key| self.send(key, attrs[key]) }
        keys.each { |key| self.send(key, attrs[key]) }
        post_keys.each { |key| self.send(key, attrs[key]) }
        # attrs.each { |key, value| self.send(key, value) }
      end

      def align(value=nil)
        return @align if value.nil?
        @align = value.to_sym if [:top, :right, :bottom, :left].include?(value.to_sym)
      end

      def position(value=nil)
        return @position || :static if value.nil?
        @position = value.to_sym if [:static, :relative, :absolute].include?(value.to_sym)
      end

      def tag(value=nil)
        return @tag if value.nil?
        @tag = $1 if value.to_s =~ /(\w+)/
      end

      def left(value=nil, units=nil)
        return @left || (@right.nil? ? nil : @right - width) if value.nil?
        return to_units(value, @left || @right - width) if value.is_a?(Symbol)
        @position = :relative if position == :static
        @left = parse_measurement_pts(value, units || self.units)
        @left = parent.width + @left if @left < 0
      end

      def top(value=nil, units=nil)
        return @top || (@bottom.nil? ? nil : @bottom - height) if value.nil?
        return to_units(value, @top || @bottom - height) if value.is_a?(Symbol)
        @position = :relative if position == :static
        @top = parse_measurement_pts(value, units || self.units)
        @top = parent.height + @top if @top < 0
      end

      def right(value=nil, units=nil)
        return @right || (@left.nil? ? nil : @left + width) if value.nil?
        return to_units(value, @right || @left + width) if value.is_a?(Symbol)
        @position = :relative if position == :static
        @right = parse_measurement_pts(value, units || self.units)
        @right = parent.width + @right if @right < 0
      end

      def bottom(value=nil, units=nil)
        return @bottom || (@top.nil? ? nil : @top + height) if value.nil?
        return to_units(value, @bottom || @top + height) if value.is_a?(Symbol)
        @position = :relative if position == :static
        @bottom = parse_measurement_pts(value, units || self.units)
        @bottom = parent.height + @bottom if @bottom < 0
      end

      def preferred_width(writer, units=:pt)
        @width || 0
      end

      def preferred_height(writer, units=:pt)
        @height || 0
      end

      def width(value=nil, units=nil)
        return @width if value.nil?
        return to_units(value, @width) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @width_pct = $1.to_f.quo(100)
          @width = @width_pct * parent.content_width
        elsif value.to_s =~ /^[+-]/
          @width = parent.content_width + parse_measurement_pts(value, units || self.units)
        else
          @width = parse_measurement_pts(value, units || self.units)
        end
      end

      def height(value=nil, units=nil)
        return @height if value.nil?
        return to_units(value, @height) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @height_pct = $1.to_f.quo(100)
          @height = @height_pct * parent.content_height
        elsif value.to_s =~ /^[+-]/
          @height = parent.content_height + parse_measurement_pts(value, units || self.units)
        else
          @height = parse_measurement_pts(value, units || self.units)
        end
      end

      def content_top(units=:pt)
        to_units(units, top + margin_top + padding_top)
      end

      def content_right(units=:pt)
        to_units(units, right - margin_right - padding_right)
      end

      def content_bottom(units=:pt)
        to_units(units, bottom - margin_bottom - padding_bottom)
      end

      def content_left(units=:pt)
        to_units(units, left + margin_left + padding_left)
      end

      def content_height(units=:pt)
        to_units(units, (height || 0) - non_content_height)
      end

      def content_width(units=:pt)
        to_units(units, (width || 0) - non_content_width)
      end

      def non_content_height
        margin_top + padding_top + padding_bottom + margin_bottom
      end

      def non_content_width
        margin_left + padding_left + padding_right + margin_right
      end

      def layout_widget(writer)
      end

      def units(value=nil)
        # inherited
        return @units || parent.units if value.nil?
        @units = value.to_sym if EideticPDF::UNIT_CONVERSION[value.to_sym]
      end

      def border(value=nil)
        return @border if value.nil?
        @border = pen_style_for(value)
        @border_top = @border_right = @border_bottom = @border_left = nil
      end

      def border_top(value=nil)
        return @border_top || @border if value.nil?
        @border_top = pen_style_for(value)
      end

      def border_right(value=nil)
        return @border_right || @border if value.nil?
        @border_right = pen_style_for(value)
      end

      def border_bottom(value=nil)
        return @border_bottom || @border if value.nil?
        @border_bottom = pen_style_for(value)
      end

      def border_left(value=nil)
        return @border_left || @border if value.nil?
        @border_left = pen_style_for(value)
      end

      def background(value=nil)
        # inherited
        # TODO
      end

      def margin_top(value=nil)
        return @margin_top || 0 if value.nil?
        return to_units(value, @margin_top) if value.is_a?(Symbol)
        @margin_top = parse_measurement_pts(value, units)
      end

      def margin_right(value=nil)
        return @margin_right || 0 if value.nil?
        return to_units(value, @margin_right) if value.is_a?(Symbol)
        @margin_right = parse_measurement_pts(value, units)
      end

      def margin_bottom(value=nil)
        return @margin_bottom || 0 if value.nil?
        return to_units(value, @margin_bottom) if value.is_a?(Symbol)
        @margin_bottom = parse_measurement_pts(value, units)
      end

      def margin_left(value=nil)
        return @margin_left || 0 if value.nil?
        return to_units(value, @margin_left) if value.is_a?(Symbol)
        @margin_left = parse_measurement_pts(value, units)
      end

      def margin(value=nil)
        return [margin_top, margin_right, margin_bottom, margin_left] if value.nil?
        return [margin_top(value), margin_right(value), margin_bottom(value), margin_left(value)] if value.is_a?(Symbol)
        if value.respond_to?(:to_str)
          value = value.split(',').map do |n|
            parse_measurement_pts(n, units)
          end
        else
          value = Array(value).map { |m| from_units(units, m) }
        end
        m = case value.size
          when 4: value
          when 2: value * 2
          when 1: value * 4
        else nil
        end
        @margin_top, @margin_right, @margin_bottom, @margin_left = m unless m.nil?
      end

      def padding_top(value=nil)
        return @padding_top || 0 if value.nil?
        return to_units(value, @padding_top) if value.is_a?(Symbol)
        @padding_top = parse_measurement_pts(value, units)
      end

      def padding_right(value=nil)
        return @padding_right || 0 if value.nil?
        return to_units(value, @padding_right) if value.is_a?(Symbol)
        @padding_right = parse_measurement_pts(value, units)
      end

      def padding_bottom(value=nil)
        return @padding_bottom || 0 if value.nil?
        return to_units(value, @padding_bottom) if value.is_a?(Symbol)
        @padding_bottom = parse_measurement_pts(value, units)
      end

      def padding_left(value=nil)
        return @padding_left || 0 if value.nil?
        return to_units(value, @padding_left) if value.is_a?(Symbol)
        @padding_left = parse_measurement_pts(value, units)
      end

      def padding(value=nil)
        return [padding_top, padding_right, padding_bottom, padding_left] if value.nil?
        return [padding_top(value), padding_right(value), padding_bottom(value), padding_left(value)] if value.is_a?(Symbol)
        if value.respond_to?(:to_str)
          value = value.split(',').map do |n|
            parse_measurement_pts(n, units)
          end
        else
          value = Array(value).map { |p| from_units(units, p) }
        end
        p = case value.size
          when 4: value
          when 2: value * 2
          when 1: value * 4
        else nil
        end
        @padding_top, @padding_right, @padding_bottom, @padding_left = p unless p.nil?
      end

      def font(value=nil)
        # inherited
        return @font || parent.font if value.nil?
        return @font || @font = parent.font.clone if value == :copy
        @font = font_style_for(value)
      end

      def font_color(value=nil)
        # TODO
      end

      def font_size(value=nil)
        # TODO
      end

      def font_style(value=nil)
        return font.style if value.nil?
        @font = font.clone
        @font.style(value)
      end

      def print(writer)
        # puts "widget: print"
        draw_border(writer)
      end

      def root
        parent.nil? ? self : parent.root
      end

      def visible(value=nil)
        return @visible.nil? ? true : @visible if value.nil?
        @visible = !!value
      end

    protected
      def attributes_first
        @attributes_first ||= %w(units).freeze
      end

      def attributes_last
        @attributes_last ||= [].freeze
      end

      def draw_border(writer)
        if [@border_top, @border_right, @border_bottom, @border_left].all? { |b| b.nil? }
          unless @border.nil?
            @border.apply(writer)
            writer.rectangle(left + margin_left, top + margin_top,
              width - margin_left - margin_right, height - margin_top - margin_bottom)
          end
        else
          unless @border_top.nil?
            @border_top.apply(writer)
            writer.move_to(left + margin_left, top + margin_top) # top left
            writer.line_to(right - margin_right, top + margin_top) # top right
          end
          unless @border_right.nil?
            @border_right.apply(writer)
            writer.move_to(right - margin_right, top + margin_top) # top right
            writer.line_to(right - margin_right, bottom - margin_bottom) # bottom right
          end
          unless @border_bottom.nil?
            @border_bottom.apply(writer)
            writer.move_to(right - margin_right, bottom - margin_bottom) # bottom right
            writer.line_to(left + margin_left, bottom - margin_bottom) # bottom left
          end
          unless @border_left.nil?
            @border_left.apply(writer)
            writer.move_to(left + margin_left, bottom - margin_bottom) # bottom left
            writer.line_to(left + margin_left, top + margin_top) # top left
          end
        end
      end

      def font_style_for(id)
        fs = root.styles.for_id(id)
        raise ArgumentError, "Font Style #{id} not found." unless fs.is_a?(Styles::FontStyle)
        fs
      end

      def pen_style_for(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Pen Style #{id} not found." unless ps.is_a?(Styles::PenStyle)
        ps
      end
    end

    class Shape < Widget
      def x(value=nil)
        # TODO
      end

      def y(value=nil)
        # TODO
      end

    protected
      def draw_border(writer)
        # suppress default behavior
      end
    end

    class Arc < Shape
      StdWidgetFactory.instance.register_widget('arc', self)

      def print(writer)
        # TODO
      end

      def r(value=nil)
        # TODO
      end

      def start_angle(value=nil)
        # TODO
      end

      def end_angle(value=nil)
        # TODO
      end
    end

    class Arch < Arc
      StdWidgetFactory.instance.register_widget('arc', self)

      def print(writer)
        # TODO
      end

      undef_method :r

      def r1(value=nil)
        # TODO
      end

      def r2(value=nil)
        # TODO
      end
    end

    class Circle < Shape
      StdWidgetFactory.instance.register_widget('circle', self)

      def clip(value=nil)
        # TODO
      end

      def print(writer)
        # TODO
      end

      def r(value=nil)
        # TODO
      end

      def reverse(value=nil)
        # TODO
      end
    end

    class Ellipse < Circle
      StdWidgetFactory.instance.register_widget('ellipse', self)

      def print(writer)
        # TODO
      end

      undef_method :r

      def rotation(value=nil)
        # TODO
      end

      def rx(value=nil)
        # TODO
      end

      def ry(value=nil)
        # TODO
      end
    end

    class Image < Widget
      StdWidgetFactory.instance.register_widget('image', self)

      def print(writer)
        # TODO
      end

      def url(value=nil)
        # TODO
      end
    end

    class Pie < Arc
      StdWidgetFactory.instance.register_widget('pie', self)

      def print(writer)
        # TODO
      end
    end

    class Polygon < Circle
      StdWidgetFactory.instance.register_widget('polygon', self)

      def print(writer)
        # TODO
      end

      def rotation(value=nil)
        # TODO
      end

      def sides(value=nil)
        # TODO
      end
    end

    class Rectangle < Shape
      StdWidgetFactory.instance.register_widget('rect', self)

      def clip(value=nil)
        # TODO
      end

      def corners(value=nil)
        return @corners if value.nil?
        value = value.split(',') if value.respond_to?(:to_str)
        @corners = value.map { |n| parse_measurement_pts(n, units) } if [1,2,4,8].include?(value.size)
      end

      def path(value=nil)
        # TODO
      end

      def print(writer)
        raise "left, top, width & height must be set" if [left, top, width, height].any? { |value| value.nil? }
        options = {}
        options[:corners] = @corners unless @corners.nil?
        super(writer)
        unless @border.nil?
          @border.apply(writer)
          writer.rectangle(left + margin_left, top + margin_top, content_width, content_height, options)
        end
      end

      def reverse(value=nil)
        # TODO
      end
    end

    class Star < Shape
      StdWidgetFactory.instance.register_widget('star', self)

      def reverse(value=nil)
        # TODO
      end

      def rotation(value=nil)
        # TODO
      end

      def points(value=nil)
        # TODO
      end

      def r(value=nil)
        # TODO
      end

      def print(writer)
        # TODO
      end
    end

    class Text < Widget
      def layout_widget(writer)
        # puts "text: layout_widget"
        super(writer)
        font.apply(writer)
      end

      def print(writer)
        super(writer)
        font.apply(writer)
      end

      def strikeout(value=nil)
        return @strikeout if value.nil?
        @strikeout = (value == true) or (value == 'true')
      end

      def text(value=nil)
        return @text || '' if value.nil?
        @text = value
      end

      def underline(value=nil)
        return @underline if value.nil?
        @underline = (value == true) or (value == 'true')
      end
    end

    class Label < Text
      StdWidgetFactory.instance.register_widget('label', self)

      def angle(value=nil)
        return @angle || 0 if value.nil?
        @angle = value
      end
    end

    class Paragraph < Text
      StdWidgetFactory.instance.register_widget('p', self)

      def bullet(value=nil)
        return @bullet.nil? ? style.bullet : @bullet if value.nil?
        @bullet = bullet_style_for(value)
      end

      def preferred_width(writer, units=:pt)
        # @preferred_width = @width || rich_text(writer).width(parent.content_width - bullet_width - non_content_width) + bullet_width + non_content_width
        @preferred_width = @width || parent.content_width
        to_units(units, @preferred_width)
      end

      def preferred_height(writer, units=:pt)
        @preferred_height = if width.nil?
          rich_text(writer).height(parent.content_width - bullet_width - non_content_width) * writer.line_height + 
            non_content_height - rich_text(writer).height.quo(writer.line_height)
        else
          rich_text(writer).height(content_width - bullet_width) * writer.line_height + 
            non_content_height - rich_text(writer).height.quo(writer.line_height)
        end
        to_units(units, @preferred_height)
      end

      def layout_widget(writer)
        # puts "paragraph: layout_widget"
        super(writer)
        @height = preferred_height(writer)
      end

      def print(writer)
        super(writer)
        options = { :align => style.align, :underline => underline, :width => content_width }
        unless bullet.nil?
          bullet.apply(writer)
          options[:bullet] = bullet.id unless bullet.nil?
        end
        # puts "paragraph_xy(#{left}, #{top}, options: #{options.inspect}"
        raise "left & top must be set #{text.inspect}" if [left, top].any? { |value| value.nil? }
        writer.paragraph_xy(content_left, content_top, @rich_text || @text, options)
      end

      def style(value=nil)
        # inherited
        return @style || parent.paragraph_style if value.nil?
        return @style || @style = parent.paragraph_style.clone if value == :copy
        @style = paragraph_style_for(value)
      end

      def text_align(value=nil)
        return @style.nil? ? parent.paragraph_style : @style.align if value.nil?
        @style = style.clone
        @style.align(value)
      end

    protected
      def bullet_style_for(id)
        bs = root.styles.for_id(id)
        raise ArgumentError, "Bullet Style #{value} not found." unless bs.is_a?(Styles::BulletStyle)
        bs
      end

      def bullet_width
        bullet.nil? ? 0 : bullet.width
      end

      def paragraph_style_for(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Paragraph Style #{id} not found." unless ps.is_a?(Styles::ParagraphStyle)
        ps
      end

      def rich_text(writer)
        if @rich_text.nil?
          font.apply(writer)
          @rich_text = EideticPDF::PdfText::RichText.new(@text, writer.font, :color => font_color, :underline => underline)
        end
        @rich_text
      end
    end

    class Container < Widget
      StdWidgetFactory.instance.register_widget('div', self)

      attr_reader :children

      def initialize(parent, attrs={})
        super(parent, attrs)
        @children = []
      end

      def layout(value=nil)
        return @layout_style if value.nil?
        @layout_style = layout_style_for(value)
      end

      def layout_container(writer)
        layout('flow') if layout.nil?
        layout.manager.layout(self, writer)
      end

      def layout_widget(writer)
        # puts "container: layout_widget"
        super(writer)
        layout_container(writer)
      end

      def paragraph_style(value=nil)
        return @paragraph_style || parent.paragraph_style if value.nil?
        @paragraph_style = paragraph_style_for(value)
      end

      def preferred_width(writer, units=:pt)
        @preferred_width = @width || parent.content_width
        to_units(units, @preferred_width)
      end

      def print(writer)
        super(writer)
        children.each { |child| child.print(writer) }
      end

    protected
      def layout_style_for(id)
        ls = root.styles.for_id(id)
        raise ArgumentError, "Layout Style #{id} not found." unless ls.is_a?(Styles::LayoutStyle)
        ls
      end

      def paragraph_style_for(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Paragraph Style #{id} not found." unless ps.is_a?(Styles::ParagraphStyle)
        ps
      end
    end

    class Page < Container
      StdWidgetFactory.instance.register_widget('page', self)

      def initialize(parent, attrs={})
        @default_margin = true
        super(parent, attrs)
      end

      def bottom(units=:pt)
        height(units)
      end

      def compress(value=nil)
        # TODO
      end

      def crop(value=nil)
        # inherited
        # TODO
      end

      def height(units=:pt)
        to_units(units, style.height)
      end

      def left(units=:pt)
        0
      end

      def margin(value=nil)
        # inherited
        return @default_margin ? parent.margin(value) : super(value) if value.nil? or value.is_a?(Symbol)
        super(value)
        @default_margin = false
      end

      def margin_top(value=nil)
        # inherited
        return @default_margin ? parent.margin_top(value) : super(value) if value.nil? or value.is_a?(Symbol)
        super(value)
        @default_margin = false
      end

      def margin_right(value=nil)
        # inherited
        return @default_margin ? parent.margin_right(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margin(margin) if @default_margin
        super(value)
        @default_margin = false
      end

      def margin_bottom(value=nil)
        # inherited
        return @default_margin ? parent.margin_bottom(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margin(margin) if @default_margin
        super(value)
        @default_margin = false
      end

      def margin_left(value=nil)
        # inherited
        return @default_margin ? parent.margin_left(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margin(margin) if @default_margin
        super(value)
        @default_margin = false
      end

      def orientation(value=nil)
        # inherited
        # TODO
      end

      def print(writer)
        writer.open_page
        layout_widget(writer)
        super(writer)
        writer.close_page
      end

      def right(units=:pt)
        width(units)
      end

      def rotate(value=nil)
        # inherited
        # TODO
      end

      def size(value=nil)
        # inherited
        # TODO
      end

      def style(value=nil)
        # inherited
        return @page_style || parent.page_style if value.nil?
        return @page_style || @page_style = parent.page_style.clone if value == :copy
        @page_style = page_style_for(value)
      end

      def top(units=:pt)
        0
      end

      def width(units=:pt)
        to_units(units, style.width)
      end

    protected
      def page_style_for(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Page Style #{id} not found." unless ps.is_a?(Styles::PageStyle)
        ps
      end
    end

    class Document < Page
      StdWidgetFactory.instance.register_widget('erml', self)

      alias :pages :children

      def initialize(parent=nil, attrs={})
        super(parent, attrs)
        @default_margin = false
        @page_style = styles.add('page', :id => 'page')
        @font = styles.add('font', :id => 'font')
        @paragraph_style = styles.add('para', :id => 'p')
        styles.add('layout', :id => 'absolute', :manager => 'absolute')
        styles.add('layout', :id => 'flow',     :manager => 'flow', :padding => 5)
        styles.add('layout', :id => 'hbox',     :manager => 'hbox')
        styles.add('layout', :id => 'vbox',     :manager => 'vbox')
        styles.add('layout', :id => 'table',    :manager => 'table')
        styles.add('pen', :id => 'solid',  :pattern => 'solid',  :color => 'Black')
        styles.add('pen', :id => 'dotted', :pattern => 'dotted', :color => 'Black')
        styles.add('pen', :id => 'dashed', :pattern => 'dashed', :color => 'Black')
      end

      def page_style(value=nil)
        return @page_style if value.nil?
        super(value)
      end

      def pages_up(value=nil)
        # TODO
      end

      def pages_up_layout(value=nil)
        # TODO
      end

      def print(writer)
        writer.open
        pages.each { |page| page.print(writer) }
        writer.close
      end

      def styles
        @styles ||= Styles::StyleCollection.new
      end

      def to_s
        writer = EideticPDF::DocumentWriter.new
        print(writer)
        writer.to_s
      end

      def units(value=nil)
        return @units || :pt if value.nil?
        super(value)
      end
    end
  end
end
