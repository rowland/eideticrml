#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

# require 'rubygems'
# require_gem 'eideticpdf'
# require 'epdfpw'
require 'erml_support'
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

      attr_reader :parent

      def initialize(parent)
        @parent = parent
        parent.children << self if parent.respond_to?(:children)
      end

      def position(value)
      end

      def size(value=nil)
      end

      def left(value=nil)
      end

      def top(value=nil)
      end

      def width(value=nil)
      end

      def height(value=nil)
      end

      def units(value=nil)
        return @units || @parent.units if value.nil?
        @units = value.to_sym if EideticPDF::UNIT_CONVERSION[value.to_sym]
      end

      def borders(value=nil)
      end

      def border_top(value=nil)
      end

      def border_right(value=nil)
      end

      def border_bottom(value=nil)
      end

      def border_left(value=nil)
      end

      def background(value=nil)
        # inherited
      end

      def font(value=nil)
        # inherited
      end
      
      def print(writer)
      end
    end

    class Shape < Widget
      def x(value=nil)
      end
      
      def y(value=nil)
      end
    end

    class Arc < Shape
      StdWidgetFactory.instance.register_widget('arc', self)

      def r(value=nil)
      end

      def start_angle(value=nil)
      end

      def end_angle(value=nil)
      end
    end

    class Arch < Arc
      StdWidgetFactory.instance.register_widget('arc', self)
 
      undef_method :r

      def r1(value=nil)
      end

      def r2(value=nil)
      end
    end

    class Circle < Shape
      StdWidgetFactory.instance.register_widget('circle', self)

      def clip(value=nil)
      end

      def r(value=nil)
      end

      def reverse(value=nil)
      end
    end

    class Ellipse < Circle
      StdWidgetFactory.instance.register_widget('ellipse', self)

      undef_method :r

      def rotation(value=nil)
      end
      
      def rx(value=nil)
      end

      def ry(value=nil)
      end
    end

    class Image < Widget
      StdWidgetFactory.instance.register_widget('image', self)

      def url(value=nil)
      end
    end

    class Pie < Arc
      StdWidgetFactory.instance.register_widget('pie', self)
    end

    class Polygon < Circle
      StdWidgetFactory.instance.register_widget('polygon', self)

      def rotation(value=nil)
      end

      def sides(value=nil)
      end
    end

    class Rectangle < Widget
      StdWidgetFactory.instance.register_widget('rect', self)

      def clip(value=nil)
      end

      def corners(value=nil)
      end

      def path(value=nil)
      end

      def reverse(value=nil)
      end
    end

    class Star < Shape
      StdWidgetFactory.instance.register_widget('star', self)

      def reverse(value=nil)
      end

      def rotation(value=nil)
      end

      def points(value=nil)
      end

      def r(value=nil)
      end
    end

    class Text < Widget
      def text(value=nil)
        return @text || '' if value.nil?
        @text = value
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
      
      def print(writer)
        writer.paragraph(@text)
      end
    end

    class Container < Widget
      StdWidgetFactory.instance.register_widget('div', self)

      attr_reader :children

      def initialize(parent)
        super(parent)
        @children = []
        @margin_top, @margin_right, @margin_bottom, @margin_left = @margins = Array.new(4, 0)
      end

      def layout(value=nil)
      end

      def margins(value=nil)
        return @margins if value.nil?
        value = value.split(',') if value.respond_to?(:to_str)
        value = value.map { |n| n.to_f }
        @margins = case value.size
          when 4: value
          when 2: value * 2
          when 1: value * 4
        else @margins
        end
        @margin_top, @margin_right, @margin_bottom, @margin_left = @margins
      end

      def margin_top(value=nil)
        return @margin_top if value.nil?
        @margins[0] = @margin_top = value.to_f
      end

      def margin_right(value=nil)
        return @margin_right if value.nil?
        @margins[1] = @margin_right = value.to_f
      end

      def margin_bottom(value=nil)
        return @margin_bottom if value.nil?
        @margins[2] = @margin_bottom = value.to_f
      end

      def margin_left(value=nil)
        return @margin_left if value.nil?
        @margins[3] = @margin_left = value.to_f
      end

      def print(writer)
        super(writer)
        children.each { |child| child.print(writer) }
      end
    end

    class Page < Container
      StdWidgetFactory.instance.register_widget('page', self)

      def initialize(parent)
        super(parent)
      end

      def crop(value=nil)
        # inherited
      end

      def size(value=nil)
        # inherited
      end
      
      def orientation(value=nil)
        # inherited
      end
      
      def rotate(value=nil)
        # inherited
      end

      def compress(value=nil)
      end

      def orientation(value=nil)
      end

      def print(writer)
        writer.open_page(:units => units, :margins => @margins)
        super(writer)
        writer.close_page
      end
    end

    class Document < Page
      StdWidgetFactory.instance.register_widget('erml', self)

      attr_reader :styles
      alias :pages :children

      def initialize(parent=nil)
        super(parent)
        @styles = []
      end

      def units(value=nil)
        return @units || :pt if value.nil?
        super(value)
      end

      def pages_up(value=nil)
      end

      def pages_up_layout(value=nil)
      end

      def print(writer)
        writer.open(:units => units, :margins => margins)
        pages.each { |page| page.print(writer) }
        writer.close
      end

      def to_s
        writer = EideticPDF::DocumentWriter.new
        print(writer)
        writer.to_s
      end
    end
  end
end
