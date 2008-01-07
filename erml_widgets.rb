#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

module EideticRML
  module Widgets
    class Widget
      def parent
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
      end
    end

    class Label < Text
      def angle(value=nil)
      end
    end

    class Paragraph < Text
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
      def style(value=nil)
      end
    end

    class Document < Container
    end
  end
end
