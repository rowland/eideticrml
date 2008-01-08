#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

require 'erml_support'

module EideticRML
  module Styles
    module ColorStyle
      def color(value=nil)
        return @color if value.nil?
        @color = value
      end
    end

    class Style
      include Support

      def id(value=nil)
        return @id if value.nil?
        @id = value.to_s
      end
    end

    class PenStyle < Style
      include ColorStyle

      def width(value=nil, units=:pt)
        return @width || 0 if value.nil?
        @width, @units = parse_measurement(value, units)
      end

      def pattern(value=nil)
        return @pattern || :solid if value.nil?
        @pattern = EideticPDF::LINE_PATTERNS[value.to_sym] ? value.to_sym : value.to_s
      end

      def units(value=nil)
        return @units || :pt if value.nil?
        @units = value.to_sym
      end
    end

    class BrushStyle < Style
      include ColorStyle
    end

    class FontStyle < Style
      include ColorStyle

      def name(value=nil)
        return @name if value.nil?
        @name = value
      end

      def size(value=nil)
        return @size if value.nil?
        @size = value.to_f
      end

      def style(value=nil)
        return @style if value.nil?
        @style = value
      end

      def encoding(value=nil)
        return @encoding if value.nil?
        @encoding = value
      end

      def sub_type(value=nil)
        return @sub_type if value.nil?
        @sub_type = value
      end
    end

    class ParagraphStyle < Style
      include ColorStyle

      def align(value=nil)
        return @align if value.nil?
        @align = value
      end

      def bullet(value=nil)
        return @bullet if value.nil?
        @bullet = value
      end
    end

    class PageStyle < Style
      def size(value=nil)
        return @size if value.nil?
        @size = value
      end

      def orientation(value=nil)
        return @orientation if value.nil?
        @orientation = value.to_sym
      end
    end

    class LayoutStyle < Style
      def padding(value=nil, units=:pt)
        return @padding if value.nil?
        @padding, @units = parse_measurement(value, units)
      end

      def hpadding(value=nil, units=:pt)
        return @hpadding || @padding if value.nil?
        @hpadding, @units = parse_measurement(value, units)
      end

      def vpadding(value=nil, units=:pt)
        return @vpadding || @padding if value.nil?
        @vpadding, @units = parse_measurement(value, units)
      end

      def manager(value=nil)
      end
    end
  end
end
