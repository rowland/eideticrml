#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

require 'erml_support'

module EideticRML
  module LayoutManagers
    class LayoutManager
      def initialize(style)
        @style = style
      end

      def layout(container, writer)
        absolute_widgets = container.children.select { |widget| widget.position == :absolute }
        layout_absolute(container, writer, absolute_widgets)
        relative_widgets = container.children.select { |widget| widget.position == :relative }
        layout_relative(container, writer, relative_widgets)
      end

      def layout_absolute(container, writer, widgets)
        widgets.each do |widget|
          widget.before_layout
          widget.left(0, :pt) if widget.left.nil? and widget.right.nil?
          widget.top(0, :pt) if widget.top.nil? and widget.bottom.nil?
          widget.width(widget.preferred_width(writer), :pt) if widget.width.nil?
          widget.layout_widget(writer)
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
        end
      end

      def layout_relative(container, writer, widgets)
        widgets.each do |widget|
          widget.before_layout
          widget.left(container.content_left, :pt) if widget.left.nil? and widget.right.nil?
          widget.top(container.content_top, :pt) if widget.top.nil? and widget.bottom.nil?
          widget.width(widget.preferred_width(writer), :pt) if widget.width.nil?
          widget.layout_widget(writer)
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
        end
      end

      def self.register(name, klass)
        (@@klasses ||= {})[name] = klass
      end

      def self.for_name(name)
        @@klasses[name] unless @@klasses.nil?
      end
      
    protected
      def printable_widgets(container, position)
        dpgno, spgno = container.root.document_page_no, container.root.section_page_no
        widgets, remaining = container.children.partition do |child|
          (child.position == :static) and (!child.printed or child.display_for_page(dpgno, spgno))
        end
      end
    end

    class AbsoluteLayout < LayoutManager
      register('absolute', self)

      def layout(container, writer)
        layout_absolute(container, writer, container.children)
      end
    end

    class FlowLayout < LayoutManager
      register('flow', self)

      def layout(container, writer)
        cx = cy = max_y = 0
        container_full = false
        widgets, remaining = printable_widgets(container, :static)
        remaining.each { |widget| widget.visible = false if widget.printed }
        widgets.each do |widget|
          widget.visible = !container_full
          next if container_full
          widget.before_layout
          widget.width(widget.preferred_width(writer), :pt) if widget.width.nil?
          if cx != 0 and cx + widget.width > container.content_width
            cy += max_y + @style.vpadding
            cx = max_y = 0
          end
          widget.left(container.content_left + cx, :pt)
          widget.top(container.content_top + cy, :pt)
          widget.layout_widget(writer)
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
          if container.bottom and widget.bottom > container.bottom
            container_full = true
            widget.visible = (cy == 0)
            next
          end
          cx += widget.width + @style.hpadding
          max_y = [max_y, widget.height].max
        end
        container.more(true) if container_full and container.overflow
        container.height(cy + max_y + container.non_content_height, :pt) if container.height.nil? and max_y > 0
        super(container, writer)
      end
    end

    class HBoxLayout < LayoutManager
      register('hbox', self)

      def layout(container, writer)
        container_full = false
        widgets, remaining = printable_widgets(container, :static)
        remaining.each { |widget| widget.visible = false if widget.printed }
        static, relative = widgets.partition { |widget| widget.position == :static }
        lpanels, unaligned = static.partition { |widget| widget.align == :left }
        rpanels, unaligned = unaligned.partition { |widget| widget.align == :right }
        percents, others = static.partition { |widget| widget.width_pct }
        specified, others = others.partition { |widget| widget.width }

        width_avail = container.content_width

        # allocate specified widths first
        specified.each do |widget|
          width_avail -= widget.width
          container_full = width_avail < 0
          widget.disabled = container_full
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
          container_full = true
          percents.each { |widget| widget.disabled = true }
        end
        width_avail -= @style.hpadding

        # divide remaining width equally among widgets with unspecified widths
        if width_avail - (others.size - 1) * @style.hpadding >= others.size
          width_avail -= (others.size - 1) * @style.hpadding
          others_width = width_avail.quo(others.size)
          others.each { |widget| widget.width(others_width, :pt) }
        else
          container_full = true
          others.each { |widget| widget.disabled = true }
        end

        static.each do |widget|
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
          if container.align == :bottom
            widget.bottom(container.content_bottom, :pt)
          else
            container_full = true
            widget.top(container.content_top, :pt)
          end
        end
        left = container.content_left
        right = container.content_right
        lpanels.each do |widget|
          next if widget.disabled
          widget.left(left, :pt)
          left += (widget.width + @style.hpadding)
        end
        rpanels.reverse.each do |widget|
          next if widget.disabled
          widget.right(right, :pt)
          right -= (widget.width + @style.hpadding)
        end
        unaligned.each do |widget|
          next if widget.disabled
          widget.left(left, :pt)
          left += (widget.width + @style.hpadding)
        end
        if container.height.nil?
          content_height = static.map { |widget| widget.height }.max || 0
          container.height(content_height + container.non_content_height, :pt)
        end
        static.each { |widget| widget.layout_widget(writer) if widget.visible and !widget.disabled }
        super(container, writer)
      end
    end

    class VBoxLayout < LayoutManager
      register('vbox', self)

      def layout(container, writer)
        # $stderr.puts "layout container: #{container.tag}"
        container_full = false
        widgets, remaining = printable_widgets(container, :static)
        remaining.each { |widget| widget.visible = false if widget.printed }
        static, relative = widgets.partition { |widget| widget.position == :static }
        headers, unaligned = static.partition { |widget| widget.align == :top }
        footers, unaligned = unaligned.partition { |widget| widget.align == :bottom }
        static.each do |widget|
          widget.before_layout
          widget.width('100%') if widget.width.nil?
          widget.left(container.content_left, :pt)
        end
        top, dy = container.content_top, 0
        # $stderr.puts "top = #{top}"
        bottom = container.content_top + container.max_content_height

        headers.each_with_index do |widget, index|
          # widget.visible = !container_full
          # next if container_full
          widget.top(top, :pt)
          widget.layout_widget(writer)
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
          # if widget.bottom > bottom
          #   container_full = true
          #   widget.visible = false
          #   next
          # end
          top += (widget.height + @style.vpadding)
          dy += widget.height + ((index > 0) ? @style.vpadding : 0)
        end
        headers.each { |widget| widget.visible = widget.bottom <= bottom }

        unless footers.empty?
          container.height('100%') if container.height.nil?
          footers.reverse.each do |widget|
            # widget.visible = !container_full
            # next if container_full
            widget.bottom(bottom, :pt)
            widget.layout_widget(writer)
            widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
            # if widget.top < top
            #   container_full = true
            #   widget.visible = false
            #   next
            # end
            bottom -= (widget.height + @style.vpadding)
          end
        end
        footers.each { |widget| widget.visible = (widget.top >= top) }

        unaligned.each_with_index do |widget, index|
          # widget.visible = !container_full
          # next if container_full
          widget.top(top, :pt)
          widget.layout_widget(writer)
          # $stderr.puts "<#{widget.tag}> after layout_widget: size = #{widget.width}, #{widget.height}"
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
          # $stderr.puts "<#{widget.tag}> position/size: #{widget.left}, #{widget.top}, #{widget.width}, #{widget.height}"
          # $stderr.puts "<#{widget.tag}> bottom = #{widget.bottom}"
          # if widget.bottom > bottom
          #   container_full = true
          #   widget.visible = (index == 0)
          #   $stderr.puts "2) <#{widget.tag}> visible: #{widget.visible}"
          # end
          top1 = top
          top += (widget.height + @style.vpadding)
          dy += widget.height + (index > 0 ? @style.vpadding : 0) if widget.visible
          # $stderr.puts "bump top: #{top1} + #{widget.height} + #{@style.vpadding} --> #{top}"
        end
        unaligned.each_with_index { |widget, index| widget.visible = (widget.bottom <= bottom) || (index == 0) }

        container_full = unaligned.last && !unaligned.last.visible
        container.more(true) if container_full and container.overflow
        # $stderr.puts "will set container <#{container.tag}> height: #{container.height.nil?} (#{top} - #{container.content_top} + #{@style.vpadding})"
        # container.height(top - container.content_top + @style.vpadding, :pt) if container.height.nil?
        container.height(dy + container.non_content_height, :pt) if container.height.nil?
        super(container, writer)
      end
    end

    class TableLayout < LayoutManager
      register('table', self)

    private
      def mark_grid(grid, a, b, c, d, value)
        c.times do |aa|
          d.times do |bb|
            grid[a + aa, b + bb] = value if aa > 0 or bb > 0
          end
        end
      end

      def row_grid(container)
        raise ArgumentError, "cols must be specified." if container.cols.nil?
        static = printable_widgets(container, :static).first
        grid = Support::Grid.new(container.cols, 0)
        row = col = 0
        static.each do |widget|
          while grid[col, row] == false
            col += 1
            if col >= container.cols then row += 1; col = 0 end
          end
          grid[col, row] = widget
          mark_grid(grid, col, row, widget.colspan, widget.rowspan, false)
          col += widget.colspan
          raise ArgumentError, "colspan causes number of columns to exceed table size." if col > container.cols
          if col == container.cols then row += 1; col = 0 end
        end
        grid
      end

      def col_grid(container)
        raise ArgumentError, "rows must be specified." if container.rows.nil?
        static = printable_widgets(container, :static).first
        grid = Support::Grid.new(0, container.rows)
        row = col = 0
        static.each do |widget|
          while grid[col, row] == false
            row += 1
            if row >= container.rows then col += 1; row = 0 end
          end
          if row >= container.rows then col += 1; row = 0 end
          grid[col, row] = widget
          mark_grid(grid, col, row, widget.colspan, widget.rowspan, false)
          row += widget.rowspan
          raise ArgumentError, "rowspan causes number of rows to exceed table size." if row > container.rows
        end
        grid
      end

      def detect_widths(grid)
        widths = []
        grid.cols.times do |c|
          col = grid.col(c)
          widget = col.detect { |w| w and (w.colspan == 1) }
          if widget.nil?
            widths << [:unspecified, 0]
          elsif widget.width_pct
            widths << [:percent, widget.width]
          elsif widget.width
            widths << [:specified, widget.width]
          else
            widths << [:unspecified, 0]
          end
        end
        widths
      end

      def allocate_specified_widths(width_avail, specified)
        specified.each do |w|
          if width_avail < w[1]
            w[1] = 0
          else
            width_avail -= (w[1] + @style.hpadding)
          end
        end
        width_avail
      end

      def allocate_percent_widths(width_avail, percents)
        # allocate percent widths with a minimum width of 1 point
        if width_avail - (percents.size - 1) * @style.hpadding >= percents.size
          width_avail -= (percents.size - 1) * @style.hpadding
          total_percents = percents.inject(0) { |total, w| total + w[1] }
          ratio = width_avail.quo(total_percents)
          percents.each do |w|
            w[1] = w[1] * ratio if ratio < 1.0
            width_avail -= w[1]
          end
        else
          percents.each { |w| w[1] = 0 }
        end
        width_avail -= @style.hpadding
        width_avail
      end

      def allocate_other_widths(width_avail, others)
        # divide remaining width equally among widgets with unspecified widths
        if width_avail - (others.size - 1) * @style.hpadding >= others.size
          width_avail -= (others.size - 1) * @style.hpadding
          others_width = width_avail.quo(others.size)
          others.each { |w| w[1] = others_width }
        else
          others.each { |w| w[1] = 0 }
        end
        width_avail
      end

      def layout_grid(grid, container, writer)
        container_full = false
        widths = detect_widths(grid)
        percents, others = widths.partition { |w| w[0] == :percent }
        specified, others = others.partition { |w| w[0] == :specified }

        width_avail = container.content_width
        width_avail = allocate_specified_widths(width_avail, specified)
        width_avail = allocate_percent_widths(width_avail, percents)
        width_avail = allocate_other_widths(width_avail, others)

        heights = Support::Grid.new(grid.cols, grid.rows)
        grid.cols.times do |c|
          grid.col(c).each_with_index do |widget, r|
            next unless widget
            if widths[c][1] > 0
              width = (0...widget.colspan).inject(0) { |width, i| width + widths[c + i][1] }
              widget.width(width + (widget.colspan - 1) * @style.hpadding, :pt)
            else
              # widget.visible = false
              widget.disabled = true
              next
            end
            heights[c, r] = [widget.rowspan, widget.height || widget.preferred_height(writer)]
          end
        end

        heights.rows.times do |r|
          row_heights = (0...heights.cols).map { |c| heights[c,r] }.compact
          min_rowspan = row_heights.map { |rowspan, height| rowspan }.min
          min_rowspan_heights = row_heights.select { |rowspan, height| rowspan == min_rowspan }
          max_height = min_rowspan_heights.map { |rowspan, height| height }.max
          heights.cols.times do |c|
            rh = heights[c,r]
            next if rh.nil?
            if rh[0] > min_rowspan
              heights[c,r+1] = [rh[0] - 1, [rh[1] - max_height, 0].max]
            end
            rh[1] = max_height
          end
        end

        top = container.content_top
        bottom = container.content_top + container.max_content_height
        grid.rows.times do |r|
          max_height = 0
          left = container.content_left
          grid.cols.times do |c|
            if widget = grid[c, r]
              widget.visible = !container_full
              next if container_full
              rh = heights[c,r]
              widget.top(top, :pt)
              widget.left(left, :pt)
              height = (0...rh[0]).inject((rh[0] - 1) * @style.vpadding) { |height, row_offset| height + heights[c,r+row_offset][1] }
              widget.height(height, :pt)
              max_height = [max_height, rh[1]].max if rh[0] == 1
            end
            left += widths[c][1] + @style.hpadding
          end
          if top + max_height > bottom
            container_full = true
            grid.cols.times { |c| grid[c, r].visible = (r == 0) }
            container.more(true) if container.overflow and (r > 0)
          end
          top += max_height + @style.vpadding
        end
        if container.height.nil?
          container.height(top - container.content_top + container.non_content_height - @style.vpadding, :pt)
        end
        static, remaining = printable_widgets(container, :static)
        remaining.each { |widget| widget.visible = false if widget.printed }
        static.each { |widget| widget.layout_widget(writer) }
      end

    public
      def layout(container, writer)
        if container.order == :rows
          grid = row_grid(container)
        else # container.order == :cols
          grid = col_grid(container)
        end
        layout_grid(grid, container, writer)
        super(container, writer)
      end
    end
  end
end
