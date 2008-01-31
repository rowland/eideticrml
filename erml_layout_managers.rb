#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

module EideticRML
  module LayoutManagers
    class LayoutManager
      def initialize(style)
        @style = style
      end

      def layout(container, writer)
      end

      def self.register(name, klass)
        (@@klasses ||= {})[name] = klass
      end

      def self.for_name(name)
        @@klasses[name] unless @@klasses.nil?
      end
    end

    class AbsoluteLayout < LayoutManager
      register('absolute', self)

      def layout(container, writer)
        # TODO
      end
    end

    class FlowLayout < LayoutManager
      register('flow', self)

      def layout(container, writer)
        cx = cy = max_y = 0
        container.children.select { |child| child.position == :static }.each do |widget|
          widget.width('100%') if widget.width.nil?
          widget.layout_widget(writer)
          if cx != 0 and cx + widget.width > container.content_width
            cy += max_y + @style.vpadding
            cx = max_y = 0
          end
          widget.left(container.left + container.margin_left + cx, :pt)
          widget.top(container.top + container.margin_top + cy, :pt)
          cx += widget.width + @style.hpadding
          max_y = [max_y, widget.height].max
        end
      end
    end

    class HBoxLayout < LayoutManager
      register('hbox', self)

      def layout(container, writer)
        # TODO
      end
    end

    class VBoxLayout < LayoutManager
      register('vbox', self)

      def layout(container, writer)
        static, relative = container.children.partition { |widget| widget.position == :static }
        headers, unaligned = static.partition { |widget| widget.align == :top }
        footers, unaligned = unaligned.partition { |widget| widget.align == :bottom }
        static.each do |widget|
          widget.width('100%') if widget.width.nil?
          widget.left(container.left + container.margin_left, :pt)
          widget.layout_widget(writer)
        end
        top = container.top + container.margin_top
        # puts "top: #{top}"
        bottom = container.bottom - container.margin_bottom
        # puts "bottom: #{bottom}"
        headers.each do |widget|
          widget.top(top, :pt)
          # puts "widget top: #{top}"
          top += (widget.height + @style.vpadding)
        end
        footers.reverse.each do |widget|
          widget.bottom(bottom, :pt)
          # puts "widget bottom: #{bottom}"
          bottom -= (widget.height + @style.vpadding)
        end
        unaligned.each do |widget|
          widget.top(top, :pt)
          # puts "unaligned top: #{top}"
          top += (widget.height + @style.vpadding)
        end
      end
    end

    class TableLayout < LayoutManager
      register('table', self)
      
      def layout(container, writer)
        # TODO
      end
    end
  end
end
