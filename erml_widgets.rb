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

      attr_reader :parent, :width_pct, :height_pct

      def initialize(parent, attrs={})
        @parent = parent
        parent.children << self if parent.respond_to?(:children)
        attrs.each { |key, value| self.send(key, value) }
      end

      def position(value)
        # TODO
      end

      def size(value=nil)
        # TODO
      end

      def left(value=nil)
        return @left || 0 if value.nil?
      end

      def top(value=nil)
        return @top || 0 if value.nil?
      end

      def width(value=nil)
        return @width || 0 if value.nil?
        if value =~ /(\d+(\.\d+)?)%/
          @width_pct = $1.to_f.quo(100)
          @width = @width_pct * from_units(parent.units, parent.content_width)
        else
          @width = value.to_f
        end
      end

      def height(value=nil)
        return @height || 0 if value.nil?
        if value =~ /(\d+(\.\d+)?)%/
          @height_pct = $1.to_f.quo(100)
          @height = @height_pct * from_units(parent.units, parent.content_height)
        else
          @height = value.to_f
        end
      end

      alias content_width width
      alias content_height height

      def units(value=nil)
        return @units || parent.units if value.nil?
        @units = value.to_sym if EideticPDF::UNIT_CONVERSION[value.to_sym]
      end

      def borders(value=nil)
        return @borders if value.nil?
        bs = root.styles.find { |style| style.id == value }
        raise ArgumentError, "Pen Style #{value} not found." unless bs.is_a?(Styles::PenStyle)
        @borders = bs
      end

      def border_top(value=nil)
        # TODO
      end

      def border_right(value=nil)
        # TODO
      end

      def border_bottom(value=nil)
        # TODO
      end

      def border_left(value=nil)
        # TODO
      end

      def background(value=nil)
        # inherited
        # TODO
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
        @borders.apply(writer) unless @borders.nil?
      end

      def root
        parent.nil? ? self : parent.root
      end

    protected
      def from_units(units, measurement)
        units == self.units ?
          measurement :
          measurement.to_f * EideticPDF::UNIT_CONVERSION[units] / EideticPDF::UNIT_CONVERSION[self.units]
      end
    end

    class Shape < Widget
      def x(value=nil)
        # TODO
      end

      def y(value=nil)
        # TODO
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

    class Rectangle < Widget
      StdWidgetFactory.instance.register_widget('rect', self)

      def clip(value=nil)
        # TODO
      end

      def corners(value=nil)
        return @corners if value.nil?
        value = value.split(',') if value.respond_to?(:to_str)
        @corners = value.map { |n| n.to_f } if [1,2,4,8].include?(value.size)
      end

      def path(value=nil)
        # TODO
      end

      def print(writer)
        options = {}
        options[:corners] = @corners unless @corners.nil?
        super(writer)
        writer.rectangle(left, top, width, height, options)
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
      def print(writer)
        font.apply(writer)
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

      def align(value=nil)
        return @style.nil? ? parent.paragraph_style : @style.align if value.nil?
        @style = style.clone
        @style.align(value)
      end

      def print(writer)
        super(writer)
        writer.paragraph(@text, :align => style.align, :underline => underline)
      end

      def style(value=nil)
        return @style || parent.paragraph_style if value.nil?
        ps = root.styles.find { |style| style.id == value }
        raise ArgumentError, "Paragraph Style #{value} not found." unless ps.is_a?(Styles::ParagraphStyle)
        @style = ps
      end
    end

    class Container < Widget
      StdWidgetFactory.instance.register_widget('div', self)

      attr_reader :children

      def initialize(parent, attrs={})
        super(parent, attrs)
        @children = []
      end

      def content_height
        height - margin_top - margin_bottom
      end

      def content_width
        width - margin_left - margin_right
      end

      def font(value=nil)
        return @font || parent.font if value.nil?
        @font = value
      end

      def layout(value=nil)
        # TODO
      end

      def margins(value=nil)
        return [margin_top, margin_right, margin_bottom, margin_left] if value.nil?
        value = value.split(',') if value.respond_to?(:to_str)
        value = value.map { |n| n.to_f }
        m = case value.size
          when 4: value
          when 2: value * 2
          when 1: value * 4
        else nil
        end
        @margin_top, @margin_right, @margin_bottom, @margin_left = m unless m.nil?
      end

      def margin_top(value=nil)
        return @margin_top || 0 if value.nil?
        @margin_top = value.to_f
      end

      def margin_right(value=nil)
        return @margin_right || 0 if value.nil?
        @margin_right = value.to_f
      end

      def margin_bottom(value=nil)
        return @margin_bottom || 0 if value.nil?
        @margin_bottom = value.to_f
      end

      def margin_left(value=nil)
        return @margin_left || 0 if value.nil?
        @margin_left = value.to_f
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

      def compress(value=nil)
        # TODO
      end

      def crop(value=nil)
        # inherited
        # TODO
      end

      def height
        from_units(:pt, style.height)
      end

      def margins(value=nil)
        return @default_margins ? parent.margins : super if value.nil?
        super(value)
        @default_margins = false
      end

      def orientation(value=nil)
        # inherited
        # TODO
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

      def print(writer)
        writer.open_page(:units => units, :margins => margins)
        super(writer)
        writer.close_page
      end

      def width
        from_units(:pt, style.width)
      end
    end

    class Document < Page
      StdWidgetFactory.instance.register_widget('erml', self)

      attr_reader :styles
      alias :pages :children

      def initialize(parent=nil, attrs={})
        super(parent, attrs)
        @default_margins = false
        @styles = []
        @page_style = Styles::PageStyle.new
        @font = Styles::FontStyle.new
        @paragraph_style = Styles::ParagraphStyle.new
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
        # writer.open(:units => units, :margins => margins)
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
