#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

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
      def children
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

      def style(value=nil)
      end
    end

    class Document < Container
      StdWidgetFactory.instance.register_widget('doc', self)
    end
  end
end
