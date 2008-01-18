#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

require 'rubygems'
require_gem 'eideticpdf'
require 'epdfpw'
require 'singleton'
require 'erml_widget_factories'

module EideticRML
  module Widgets
    class StdWidgetFactory < WidgetFactory
      include Singleton

      WidgetFactory.register_factory('std', self.instance)
    end

    class Widget
      attr_reader :parent

      def initialize(parent)
        @parent = parent
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
    end

    class Container < Widget
      StdWidgetFactory.instance.register_widget('div', self)

      attr_reader :children

      def initialize
        @children = []
      end

      def layout(value=nil)
      end

      def margins(*margins)
      end

      def margin_top(value=nil)
      end

      def margin_right(value=nil)
      end

      def margin_bottom(value=nil)
      end

      def margin_left(value=nil)
      end
    end

    class Page < Container
      StdWidgetFactory.instance.register_widget('page', self)

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
    end

    class Document < Page
      StdWidgetFactory.instance.register_widget('erml', self)

      attr_reader :styles
      alias :pages :children

      def initialize
        @styles = []
      end

      def pages_up(value=nil)
      end

      def pages_up_layout(value=nil)
      end

      def print(writer)
        writer.open
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
