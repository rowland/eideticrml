#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

module EideticRML
  module Styles
    class Style
      def id(value=nil)
      end
    end

    class PenStyle < Style
      def width(value=nil)
      end

      def color(value=nil)
      end

      def pattern(value=nil)
      end
    end

    class BrushStyle < Style
      def color(value=nil)
      end
    end

    class FontStyle < Style
      def name(value=nil)
      end

      def size(value=nil)
      end

      def style(value=nil)
      end

      def color(value=nil)
      end

      def encoding(value=nil)
      end

      def sub_type(value=nil)
      end
    end

    class ParagraphStyle < Style
      def align(value=nil)
      end

      def bullet(value=nil)
      end
    end

    class PageStyle < Style
      def size(value=nil)
      end

      def landscape(value=nil)
      end
    end

    class LayoutStyle < Style
      def padding(value=nil)
      end

      def hpadding(value=nil)
      end

      def vpadding(value=nil)
      end

      def manager(value=nil)
      end
    end
  end
end
