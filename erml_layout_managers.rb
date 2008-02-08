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
          widget.width(widget.preferred_width(writer), :pt) if widget.width.nil?
          if cx != 0 and cx + widget.width > container.content_width
            cy += max_y + @style.vpadding
            cx = max_y = 0
          end
          widget.left(container.content_left + cx, :pt)
          widget.top(container.content_top + cy, :pt)
          widget.layout_widget(writer)
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
          cx += widget.width + @style.hpadding
          max_y = [max_y, widget.height].max
        end
      end
    end

    class HBoxLayout < LayoutManager
      register('hbox', self)

      def layout(container, writer)
        static, relative = container.children.partition { |widget| widget.position == :static }
        lpanels, unaligned = static.partition { |widget| widget.align == :left }
        rpanels, unaligned = unaligned.partition { |widget| widget.align == :right }
        percents, others = static.partition { |widget| widget.width_pct }
        specified, others = others.partition { |widget| widget.width }

        width_avail = container.content_width

        # allocate specified widths first
        specified.each do |widget|
          width_avail -= widget.width
          widget.visible(false) if width_avail < 0
          width_avail -= @style.hpadding
        end

        # allocate percent widths next, with a minimum width of 1 point
        if width_avail - (percents.size - 1) * @style.hpadding >= percents.size
          width_avail -= (percents.size - 1) * @style.hpadding
          total_percents = percents.inject(0) { |total, widget| total + widget.width }
          ratio = width_avail.quo(total_percents)
          percents.each do |widget|
            widget.width(widget.width * ratio, :pt) if ratio < 1.0
            width_avail -= widget.width
          end
        else
          percents.each { |widget| widget.visible(false) }
        end
        width_avail -= @style.hpadding

        # divide remaining width equally among widgets with unspecified widths
        if width_avail - (others.size - 1) * @style.hpadding >= others.size
          width_avail -= (others.size - 1) * @style.hpadding
          others_width = width_avail.quo(others.size)
          others.each { |widget| widget.width(others_width, :pt) }
        else
          others.each { |widget| widget.visible(false) }
        end

        static.each do |widget|
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
          widget.top(container.content_top, :pt)
        end
        left = container.content_left
        # puts "left: #{left}"
        right = container.content_right
        # puts "right: #{right}"
        lpanels.each do |widget|
          next unless widget.visible
          widget.left(left, :pt)
          # puts "widget left: #{left}"
          left += (widget.width + @style.hpadding)
        end
        rpanels.reverse.each do |widget|
          next unless widget.visible
          widget.right(right, :pt)
          # puts "widget right: #{right}"
          right -= (widget.width + @style.hpadding)
        end
        unaligned.each do |widget|
          next unless widget.visible
          widget.left(left, :pt)
          # puts "unaligned left: #{left}"
          left += (widget.width + @style.hpadding)
        end
        if container.height.nil?
          content_height = static.map { |widget| widget.height }.max || 0
          container.height(content_height + container.non_content_height, :pt)
        end
        container.children.each { |widget| widget.layout_widget(writer) }
      end

      def preferred_width(container, writer)
      end

      def preferred_height(container, writer)
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
          widget.layout_widget(writer)
          widget.left(container.content_left, :pt)
          widget.layout_widget(writer)
        end
        top = container.content_top
        # puts "top: #{top}"
        bottom = container.content_bottom
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
