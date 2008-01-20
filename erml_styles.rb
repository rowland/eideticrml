#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

require 'erml_support'

module EideticRML
  module Styles
    module ColorStyle
      def color(value=nil)
        return @color || 0 if value.nil?
        @color = value
      end
    end

    class Style
      include Support

      def initialize(attrs={})
        attrs.each { |key, value| self.send(key, value) }
      end

      def id(value=nil)
        return @id if value.nil?
        @id = value.to_s
      end
    end

    class PenStyle < Style
      include ColorStyle

      def apply(writer)
      end

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

      def apply(writer)
      end
    end

    class FontStyle < Style
      include ColorStyle

      def apply(writer)
        writer.font(name, size, :style => style, :color => color, :encoding => encoding, :sub_type => sub_type)
      end

      def name(value=nil)
        return @name || EideticPDF::PageWriter::DEFAULT_FONT[:name] if value.nil?
        @name = value
      end

      def size(value=nil)
        return @size || EideticPDF::PageWriter::DEFAULT_FONT[:size] if value.nil?
        @size = value.to_f
      end

      def style(value=nil)
        return @style || '' if value.nil?
        @style = value
      end

      def encoding(value=nil)
        return @encoding || 'WinAnsiEncoding' if value.nil?
        @encoding = value
      end

      def sub_type(value=nil)
        return @sub_type || 'Type1' if value.nil?
        @sub_type = value
      end
    end

    class ParagraphStyle < Style
      include ColorStyle

      def align(value=nil)
        return @align || :left if value.nil?
        @align = [:left, :center, :right, :justify].include?(value.to_sym) ? value.to_sym : @align
      end

      def bullet(value=nil)
        return @bullet if value.nil?
        @bullet = value
      end
    end

    class PageStyle < Style
      def size(value=nil)
        return @size || :letter if value.nil?
        @size = value.to_sym if EideticPDF::PageStyle::SIZES[value.to_sym]
      end

      def orientation(value=nil)
        return @orientation || :portrait if value.nil?
        @orientation = value.to_sym if [:portrait, :landscape].include?(value.to_sym)
      end
    end

    class LayoutStyle < Style
      def padding(value=nil, units=:pt)
        return @padding || 0 if value.nil?
        @padding, @units = parse_measurement(value, units)
      end

      def hpadding(value=nil, units=:pt)
        return @hpadding || padding if value.nil?
        @hpadding, @units = parse_measurement(value, units)
      end

      def vpadding(value=nil, units=:pt)
        return @vpadding || padding if value.nil?
        @vpadding, @units = parse_measurement(value, units)
      end

      def units(value=nil)
        return @units || :pt if value.nil?
        @units = value.to_sym if EideticPDF::UNIT_CONVERSION[value.to_sym]
      end

      def manager(value=nil) # TODO
      end
    end
  end
end
