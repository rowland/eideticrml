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
        attrs.each { |key, value| self.send(key, value) }
      end

      def align(value=nil)
        return @align if value.nil?
        @align = value.to_sym if [:top, :right, :bottom, :left].include?(value.to_sym)
      end

      def position(value=nil)
        return @position || :static if value.nil?
        @position = value.to_sym if [:static, :relative, :absolute].include?(value.to_sym)
      end

      def size(value=nil)
        # TODO
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

      def width(value=nil, units=nil)
        return @width if value.nil?
        return to_units(value, @width) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @width_pct = $1.to_f.quo(100)
          @width = @width_pct * parent.content_width
        else
          @width = parse_measurement_pts(value, units || self.units)
        end
      end

      def height(value=nil)
        return @height if value.nil?
        return to_units(value, @height) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @height_pct = $1.to_f.quo(100)
          @height = @height_pct * parent.content_height
        else
          @height = parse_measurement_pts(value, units)
        end
      end

      def content_height(units=:pt)
        height(units) - margin_top(units) - margin_bottom(units)
      end

      def content_width(units=:pt)
        width(units) - margin_left(units) - margin_right(units)
      end

      def layout_widget(writer)
        # puts "widget: layout_widget"
        # @left ||= 0
        # @top ||= 0
        # @width ||= 0
        # @height ||= 0
      end

      def units(value=nil)
        return @units || parent.units if value.nil?
        @units = value.to_sym if EideticPDF::UNIT_CONVERSION[value.to_sym]
      end

      def borders(value=nil)
        return @borders if value.nil?
        @borders = pen_style(value)
        @border_top = @border_right = @border_bottom = @border_left = nil
      end

      def border_top(value=nil)
        return @border_top || @borders if value.nil?
        @border_top = pen_style(value)
      end

      def border_right(value=nil)
        return @border_right || @borders if value.nil?
        @border_right = pen_style(value)
      end

      def border_bottom(value=nil)
        return @border_bottom || @borders if value.nil?
        @border_bottom = pen_style(value)
      end

      def border_left(value=nil)
        return @border_left || @borders if value.nil?
        @border_left = pen_style(value)
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

      def margins(value=nil)
        return [margin_top, margin_right, margin_bottom, margin_left] if value.nil?
        return [margin_top(value), margin_right(value), margin_bottom(value), margin_left(value)] if value.is_a?(Symbol)
        if value.respond_to?(:to_str)
          value = value.split(',').map do |n|
            parse_measurement_pts(n, units)
          end
        end
        m = case value.size
          when 4: value
          when 2: value * 2
          when 1: value * 4
        else nil
        end
        # puts "setting margins: #{m.inspect}"
        @margin_top, @margin_right, @margin_bottom, @margin_left = m unless m.nil?
      end

      def font(value=nil)
        return @font || parent.font if value.nil?
        f = root.styles.find { |style| style.id == value }
        raise ArgumentError, "Font Style #{value} not found." unless f.is_a?(Styles::FontStyle)
        @font = f
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
        draw_borders(writer)
      end

      def root
        parent.nil? ? self : parent.root
      end

    protected
      def pen_style(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Pen Style #{id} not found." unless ps.is_a?(Styles::PenStyle)
        ps
      end

      def draw_borders(writer)
        if [@border_top, @border_right, @border_bottom, @border_left].all? { |b| b.nil? }
          unless @borders.nil?
            @borders.apply(writer)
            writer.rectangle(left + margin_left, top + margin_top, content_width, content_height)
          end
        else
          unless @border_top.nil?
            @border_top.apply(writer)
            writer.move_to(left + margin_left, top + margin_top) # top left
            writer.line_to(left + margin_left + content_width, top + margin_top) # top right
          end
          unless @border_right.nil?
            @border_right.apply(writer)
            writer.move_to(left + margin_left + content_width, top + margin_top) # top right
            writer.line_to(left + margin_left + content_width, top + margin_top + content_height) # bottom right
          end
          unless @border_bottom.nil?
            @border_bottom.apply(writer)
            writer.move_to(left + margin_left + content_width, top + margin_top + content_height) # bottom right
            writer.line_to(left + margin_left, top + margin_top + content_height) # bottom left
          end
          unless @border_left.nil?
            @border_left.apply(writer)
            writer.move_to(left + margin_left, top + margin_top + content_height) # bottom left
            writer.line_to(left + margin_left, top + margin_top) # top left
          end
        end
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
      def draw_borders(writer)
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
        # $stdout.puts [@left, @top, @width, @height, @right, @bottom].inspect if @align == :bottom
        raise "left, top, width & height must be set" if [left, top, width, height].any? { |value| value.nil? }
        options = {}
        options[:corners] = @corners unless @corners.nil?
        super(writer)
        unless @borders.nil?
          @borders.apply(writer)
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
        bs = root.styles.for_id(value)
        raise ArgumentError, "Bullet Style #{value} not found." unless bs.is_a?(Styles::BulletStyle)
        @bullet = bs
      end

      def layout_widget(writer)
        # puts "paragraph: layout_widget"
        super(writer)
        bullet_width = bullet.nil? ? 0 : bullet.width
        @rich_text ||= EideticPDF::PdfText::RichText.new(@text, writer.font, :color => font_color, :underline => underline)
        @height = @rich_text.height(width - bullet_width) * writer.line_height
        # puts "paragraph @height: #{@height} for width: #{width}"
      end

      def print(writer)
        super(writer)
        options = { :align => style.align, :underline => underline, :width => width }
        unless bullet.nil?
          bullet.apply(writer)
          options[:bullet] = bullet.id unless bullet.nil?
        end
        # puts "paragraph_xy(#{left}, #{top}, options: #{options.inspect}"
        raise "left & top must be set #{text.inspect}" if [left, top].any? { |value| value.nil? }
        writer.paragraph_xy(left, top, @rich_text || @text, options)
        # writer.rectangle(left, top, width, height, :borders => 0)
      end

      def style(value=nil)
        return @style || parent.paragraph_style if value.nil?
        ps = root.styles.find { |style| style.id == value }
        raise ArgumentError, "Paragraph Style #{value} not found." unless ps.is_a?(Styles::ParagraphStyle)
        @style = ps
      end

      def text_align(value=nil)
        return @style.nil? ? parent.paragraph_style : @style.align if value.nil?
        @style = style.clone
        @style.align(value)
      end
    end

    class Container < Widget
      StdWidgetFactory.instance.register_widget('div', self)

      attr_reader :children

      def initialize(parent, attrs={})
        super(parent, attrs)
        @children = []
      end

      def font(value=nil)
        return @font || parent.font if value.nil?
        @font = value
      end

      def layout(value=nil)
        return @layout_style if value.nil?
        ls = root.styles.find { |style| style.id == value }
        raise ArgumentError, "Layout Style #{value} not found." unless ls.is_a?(Styles::LayoutStyle)
        @layout_style = ls
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
        ps = root.styles.find { |style| style.id == value }
        raise ArgumentError, "Paragraph Style #{value} not found." unless ps.is_a?(Styles::ParagraphStyle)
        @paragraph_style = ps
      end

      def print(writer)
        super(writer)
        children.each { |child| child.print(writer) }
      end
    end

    class Page < Container
      StdWidgetFactory.instance.register_widget('page', self)

      def initialize(parent, attrs={})
        @default_margins = true
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

      def margins(value=nil)
        return @default_margins ? parent.margins(value) : super(value) if value.nil? or value.is_a?(Symbol)
        super(value)
        @default_margins = false
      end

      def margin_top(value=nil)
        return @default_margins ? parent.margin_top(value) : super(value) if value.nil? or value.is_a?(Symbol)
        super(value)
        @default_margins = false
      end

      def margin_right(value=nil)
        return @default_margins ? parent.margin_right(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margins(margins) if @default_margins
        super(value)
        @default_margins = false
      end

      def margin_bottom(value=nil)
        return @default_margins ? parent.margin_bottom(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margins(margins) if @default_margins
        super(value)
        @default_margins = false
      end

      def margin_left(value=nil)
        return @default_margins ? parent.margin_left(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margins(margins) if @default_margins
        super(value)
        @default_margins = false
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
        return @page_style || parent.page_style if value.nil?
        ps = root.styles.find { |style| style.id == value }
        raise ArgumentError, "Page Style #{value} not found." unless ps.is_a?(Styles::PageStyle)
        @page_style = ps
      end

      def top(units=:pt)
        0
      end

      def width(units=:pt)
        to_units(units, style.width)
      end
    end

    class Document < Page
      StdWidgetFactory.instance.register_widget('erml', self)

      attr_reader :styles
      alias :pages :children

      def initialize(parent=nil, attrs={})
        super(parent, attrs)
        @default_margins = false
        @styles = Styles::StyleCollection.new
        @page_style = styles.add('page')
        @font = styles.add('font')
        @paragraph_style = styles.add('para')
        styles.add('layout', :id => 'absolute', :manager => 'absolute')
        styles.add('layout', :id => 'flow',     :manager => 'flow')
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
