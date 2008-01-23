#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

require 'erml_support'
require 'erml_layout_managers'

module EideticRML
  module Styles
    module HasColor
      def color(value=nil)
        return @color || 0 if value.nil?
        @color = value
      end
    end

    module HasWidth
      def width(value=nil, units=:pt)
        return @width || 0 if value.nil?
        @width, @units = parse_measurement(value, units)
      end

      def units(value=nil)
        return @units || :pt if value.nil?
        @units = value.to_sym
      end
    end

    class Style
      include Support

      def initialize(styles, attrs={})
        @styles = styles
        attrs.each { |key, value| self.send(key, value) }
      end

      def id(value=nil)
        return @id if value.nil?
        @id = value.to_s
      end

      def self.register(name, klass)
        (@@klasses ||= {})[name] = klass
      end

      def self.for_name(name)
        @@klasses[name] unless @@klasses.nil?
      end
    end

    class StyleCollection < Array
      def add(name, attrs={})
        style = Style.for_name(name).new(self, attrs)
        self << style
        style
      end
    end

    class PenStyle < Style
      register('pen', self)

      include HasColor
      include HasWidth

      def apply(writer)
        writer.line_color(color)
        writer.line_width(width, units)
        writer.line_dash_pattern(pattern)
      end

      def pattern(value=nil)
        return @pattern || :solid if value.nil?
        @pattern = EideticPDF::LINE_PATTERNS[value.to_sym] ? value.to_sym : value.to_s
      end
    end

    class BrushStyle < Style
      register('brush', self)

      include HasColor

      def apply(writer)
      end
    end

    class FontStyle < Style
      register('font', self)

      include HasColor

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

    class BulletStyle < Style
      register('bullet', self)

      include HasWidth

      def apply(writer)
        unless writer.bullet(id)
          writer.bullet(id, :width => width, :units => units) do |w|
            prev_font = w.font(font, 12)
            w.print(text)
            w.font(prev_font)
          end
        end
      end

      def font(value=nil)
        return @font if value.nil?
        @font = value
      end

      def text(value=nil)
        return @text if value.nil?
        @text = value
      end
    end

    class ParagraphStyle < Style
      register('para', self)

      include HasColor

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
      register('page', self)

      def height
        EideticPDF::PageStyle::SIZES[size][orientation == :portrait ? 1 : 0]
      end

      def orientation(value=nil)
        return @orientation || :portrait if value.nil?
        @orientation = value.to_sym if [:portrait, :landscape].include?(value.to_sym)
      end

      def size(value=nil)
        return @size || :letter if value.nil?
        @size = value.to_sym if EideticPDF::PageStyle::SIZES[value.to_sym]
      end

      def width
        EideticPDF::PageStyle::SIZES[size][orientation == :portrait ? 0 : 1]
      end
    end

    class LayoutStyle < Style
      register('layout', self)

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

      def manager(value=nil)
        return @manager if value.nil?
        @manager = LayoutManagers::LayoutManager.for_name(value)
      end
    end
  end
end
