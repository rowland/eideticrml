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

      def row_grid(container)
        grid = Support::Grid.new(container.children.size, 1)
        container.children.each_with_index do |widget, index|
          grid[index, 0] = widget
        end
        grid
      end

      def col_grid(container)
        grid = Support::Grid.new(1, container.children.size)
        container.children.each_with_index do |widget, index|
          grid[0, index] = widget
        end
        grid
      end

      def layout(container, writer)
        absolute_widgets = container.children.select { |widget| widget.position == :absolute }
        layout_absolute(container, writer, absolute_widgets)
        relative_widgets = container.children.select { |widget| widget.position == :relative }
        layout_relative(container, writer, relative_widgets)
        container.children.each { |widget| container.root_page.positioned_widgets[widget.position] += 1 if widget.visible and widget.leaf? }
        # $stderr.puts "+++base+++ #{container.root_page.positioned_widgets[:static]}"
      end

      def layout_absolute(container, writer, widgets)
        widgets.each do |widget|
          widget.before_layout
          widget.position(:absolute)
          widget.left(0, :pt) if widget.left.nil? and widget.right.nil?
          widget.top(0, :pt) if widget.top.nil? and widget.bottom.nil?
          widget.width(widget.preferred_width(writer), :pt) if widget.width.nil?
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil? # swapped
          widget.layout_widget(writer)                                              # swapped
        end
      end

      def layout_relative(container, writer, widgets)
        widgets.each do |widget|
          widget.before_layout
          widget.position(:relative) if widget.position == :static
          widget.left(0, :pt) if widget.left.nil? and widget.right.nil?
          widget.top(0, :pt) if widget.top.nil? and widget.bottom.nil?
          widget.width(widget.preferred_width(writer), :pt) if widget.width.nil?
          widget.layout_widget(writer)
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil?
        end
      end

      def after_layout(container)
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

      alias :grid :row_grid

      def layout(container, writer)
        layout_absolute(container, writer, container.children)
      end

      def preferred_height(grid, writer)
        return grid.row(0).empty? ? 0 : nil
      end

      def preferred_width(grid, writer)
        return grid.row(0).empty? ? 0 : nil
      end
    end

    class FlowLayout < LayoutManager
      register('flow', self)

      alias :grid :row_grid

      def layout(container, writer)
        cx = cy = max_y = 0
        container_full = false
        bottom = container.content_top + container.max_content_height
        widgets, remaining = printable_widgets(container, :static)
        remaining.each { |widget| widget.visible = false if widget.printed }
        widgets.each do |widget|
          widget.visible = !container_full
          next if container_full
          widget.before_layout
          widget.width([widget.preferred_width(writer) || container.content_width, container.content_width].min, :pt) if widget.width.nil?
          # puts "flow widget width: #{widget.width} #{widget.path}"
          if cx != 0 and cx + widget.width > container.content_width
            cy += max_y + @style.vpadding
            cx = max_y = 0
          end
          widget.left(container.content_left + cx, :pt)
          widget.top(container.content_top + cy, :pt)
          widget.height(widget.preferred_height(writer) || 0, :pt) if widget.height.nil? # swapped
          widget.layout_widget(writer)                                                   # swapped
          # if container.bottom and widget.bottom > container.bottom
          if widget.bottom > bottom
            container_full = true
            # widget.visible = (cy == 0)
            widget.visible = container.root_page.positioned_widgets[:static] == 0
            # $stderr.puts "+++flow+++ #{container.root_page.positioned_widgets[:static]}, visible: #{widget.visible}"
            next
          end
          container.root_page.positioned_widgets[widget.position] += 1
          cx += widget.width + @style.hpadding
          max_y = [max_y, widget.height].max
        end
        container.more(true) if container_full and container.overflow
        container.height(cy + max_y + container.non_content_height, :pt) if container.height.nil? and max_y > 0
        super(container, writer)
      end

      def preferred_height(grid, writer)
        cells = grid.row(0)
        return 0 if cells.empty?
        cell_heights = cells.map { |w| w.preferred_height(writer) }
        return nil unless cell_heights.all?
        cell_heights.max
      end

      def preferred_width(grid, writer)
        cells = grid.row(0)
        return 0 if cells.empty?
        cell_widths = cells.map { |w| w.preferred_width(writer) }
        return nil unless cell_widths.all?
        cell_widths.inject((cells.size - 1) * @style.hpadding) { |sum, width| sum + width }
      end
    end

    class HBoxLayout < LayoutManager
      register('hbox', self)

      alias :grid :row_grid

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

      def preferred_height(grid, writer)
        cells = grid.row(0)
        return 0 if cells.empty?
        cell_heights = cells.map { |w| w.preferred_height(writer) }
        return nil unless cell_heights.all?
        cell_heights.max
      end

      def preferred_width(grid, writer)
        cells = grid.row(0)
        return 0 if cells.empty?
        cell_widths = cells.map { |w| w.preferred_width(writer) }
        return nil unless cell_widths.all?
        cell_widths.inject((cells.size - 1) * @style.hpadding) { |sum, width| sum + width }
      end
    end

    class VBoxLayout < LayoutManager
      register('vbox', self)

      alias :grid :col_grid

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
          # puts "<1> vbox widget width: #{widget.width} #{widget.path}"
          widget.width([widget.preferred_width(writer) || container.content_width, container.content_width].min, :pt) if widget.width.nil?
          # puts "<2> vbox widget width: #{widget.width} #{widget.path}"
          widget.left(container.content_left, :pt)
        end
        top, dy = container.content_top, 0
        bottom = container.content_top + container.max_content_height

        headers.each_with_index do |widget, index|
          widget.top(top, :pt)
          widget.layout_widget(writer)                                              # swapped
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil? # swapped
          top += (widget.height + @style.vpadding)
          dy += widget.height + ((index > 0) ? @style.vpadding : 0)
        end
        headers.each { |widget| widget.visible = (widget.bottom <= bottom) } # or first static widget?

        unless footers.empty?
          container.height('100%') if container.height.nil?
          footers.reverse.each do |widget|
            widget.bottom(bottom, :pt)
            widget.layout_widget(writer)                                              # swapped
            widget.height(widget.preferred_height(writer), :pt) if widget.height.nil? # swapped
            bottom -= (widget.height + @style.vpadding)
          end
        end
        footers.each { |widget| widget.visible = (widget.top >= top) } # or first static widget?

        widgets_visible = 0
        unaligned.each_with_index do |widget, index|
          widget.visible = !container_full
          next if container_full
          widget.top(top, :pt)
          # puts "<1> vbox widget height: #{widget.height} #{widget.path}"
          widget.layout_widget(writer)                                              # swapped
          # puts "<2> vbox widget height: #{widget.height} #{widget.path}"
          widget.height(widget.preferred_height(writer), :pt) if widget.height.nil? # swapped
          # puts "<3> vbox widget height: #{widget.height} #{widget.path}"
          top += widget.height
          dy += widget.height + (index > 0 ? @style.vpadding : 0) #if widget.visible
          if top > bottom
            container_full = true
            widget.visible = (widgets_visible == 0)
            # widget.visible = widget.leaves > 0 and container.root_page.positioned_widgets[:static] == 0
            # $stderr.puts "+++vbox+++ #{container.root_page.positioned_widgets[:static]}, tag: #{widget.tag}, visible: #{widget.visible}"
          end
          widgets_visible += 1 if widget.visible
          top += @style.vpadding
        end
        # set_height = container.height.nil?
        # container.height(container.max_height_avail, :pt) if set_height
        # unaligned.each_with_index do |widget, index|
        #   # widget.visible = (widget.bottom <= bottom) || (index == 0) #|| (container.overflow && widget.top < bottom)
        #   widget.visible = (widget.bottom <= bottom) || (container.root_page.positioned_widgets[:static] == 0) #|| (container.overflow && widget.top < bottom)
        #   # if widget.visible and widget.bottom > bottom and container.overflow
        #   #   widget.layout_widget(writer)
        #   # end
        # end

        container_full = unaligned.last && !unaligned.last.visible
        container.more(true) if container_full and container.overflow
        # container.height(top - container.content_top + @style.vpadding, :pt) if container.height.nil?
        # container.height(dy + container.non_content_height, :pt) if container.height.nil?
        super(container, writer)
      end

      def preferred_height(grid, writer)
        cells = grid.col(0)
        return 0 if cells.empty?
        cell_heights = cells.map { |w| w.preferred_height(writer) }
        return nil unless cell_heights.all?
        cell_heights.inject((cells.size - 1) * @style.vpadding) { |sum, height| sum + height }
      end

      def preferred_width(grid, writer)
        cells = grid.col(0)
        return 0 if cells.empty?
        cell_widths = cells.map { |w| w.preferred_width(writer) }
        return nil unless cell_widths.all?
        cell_widths.max
      end

      # def after_layout(container)
      #   container.children.each do |widget|
      #     if widget.visible and widget.position == :static
      #       if widget.bottom > container.content_bottom
      #         widget.disabled = !container.overflow
      #       end
      #       # widget.after_layout if widget.visible
      #     end
      #   end
      # end
    end

    class TableLayout < LayoutManager
      register('table', self)

    private
      ROW_SPAN   = 0
      COL_SPAN   = 0
      ROW_HEIGHT = 1
      COL_WIDTH  = 1
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

      def detect_widths(grid, writer)
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
            widths << [:unspecified, col.map { |w| w ? w.preferred_width(writer) : 0 }.max]
          end
        end
        widths
      end

      def allocate_specified_widths(width_avail, specified)
        specified.each do |w|
          if width_avail < w[COL_WIDTH]
            w[COL_WIDTH] = 0
          else
            width_avail -= (w[COL_WIDTH] + @style.hpadding)
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
        widths = detect_widths(grid, writer)
        if container.width.nil?
          puts "Noooooooo!!!!"
        end
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
            if widths[c][COL_WIDTH] > 0
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
            if rh[ROW_SPAN] > min_rowspan
              heights[c,r+1] = [rh[ROW_SPAN] - 1, [rh[ROW_HEIGHT] - max_height, 0].max]
            end
            rh[ROW_HEIGHT] = max_height
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
              next if rh.nil?
              widget.top(top, :pt)
              widget.left(left, :pt)
              height = (0...rh[ROW_SPAN]).inject((rh[ROW_SPAN] - 1) * @style.vpadding) { |height, row_offset| height + heights[c,r+row_offset][ROW_HEIGHT] }
              widget.height(height, :pt)
              max_height = [max_height, rh[ROW_HEIGHT]].max if rh[ROW_SPAN] == 1
            end
            left += widths[c][1] + @style.hpadding
          end
          if top + max_height > bottom
            container_full = true
            grid.cols.times { |c| grid[c, r].visible = (r == 0) if grid[c, r] }
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
      def grid(container)
        if container.order == :rows
          row_grid(container)
        else # container.order == :cols
          col_grid(container)
        end
      end

      def layout(container, writer)
        layout_grid(grid(container), container, writer)
        super(container, writer)
      end

      def preferred_height(grid, writer)
        # calculate preferred heights, where available
        heights = Support::Grid.new(grid.cols, grid.rows)
        return 0 if heights.cols == 0 or heights.rows == 0
        grid.cols.times do |c|
          grid.col(c).each_with_index do |widget, r|
            next unless widget
            # heights[c, r] = [widget.rowspan, widget.has_height? ? widget.preferred_height(writer) : nil]
            heights[c, r] = [widget.rowspan, widget.preferred_height(writer)]
          end
        end

        heights.rows.times do |r|
          row_heights = (0...heights.cols).map { |c| heights[c,r] }.compact
          min_rowspan = row_heights.map { |rowspan, height| rowspan }.min
          min_rowspan_heights = row_heights.select { |rowspan, height| rowspan == min_rowspan }
          max_height = min_rowspan_heights.map { |rowspan, height| height }.compact.max
          # at least one cell must specify a height
          return nil if max_height.nil?
          heights.cols.times do |c|
            rh = heights[c,r]
            next if rh.nil?
            # carry height in excess of max height of cells with min_rowspan to cell in next row, subtracting vpadding
            if rh[ROW_SPAN] > min_rowspan
              heights[c,r+1] = [rh[ROW_SPAN] - 1, [rh[ROW_HEIGHT] - max_height - @style.vpadding, 0].max]
            end
            rh[ROW_HEIGHT] = max_height
          end
        end

        result = 0
        grid.rows.times do |r|
          max_height = 0
          grid.cols.times do |c|
            if (widget = grid[c, r]) and (rh = heights[c,r])
              height = (0...rh[ROW_SPAN]).inject((rh[ROW_SPAN] - 1) * @style.vpadding) { |height, row_offset| height + heights[c,r+row_offset][ROW_HEIGHT] }
              max_height = [max_height, rh[ROW_HEIGHT]].max if rh[ROW_SPAN] == 1
            end
          end
          result += max_height + @style.vpadding
        end
        result -= @style.vpadding if result > 0
      end

      def preferred_width(grid, writer)
        # calculate preferred widths, where available
        widths = Support::Grid.new(grid.cols, grid.rows)
        return 0 if widths.cols == 0 or widths.rows == 0
        grid.rows.times do |r|
          grid.row(r).each_with_index do |widget, c|
            next unless widget
            # widths[c, r] = [widget.colspan, widget.has_width? ? widget.preferred_width(writer) : nil]
            widths[c, r] = [widget.colspan, widget.preferred_width(writer)]
          end
        end

        widths.cols.times do |c|
          col_widths = (0...widths.rows).map { |r| widths[c,r] }.compact
          min_colspan = col_widths.map { |colspan, width| colspan }.min
          min_colspan_widths = col_widths.select { |colspan, width| colspan == min_colspan }
          max_width = min_colspan_widths.map { |colspan, width| width }.compact.max
          # at least one cell must specify a width
          return nil if max_width.nil?
          widths.rows.times do |r|
            cw = widths[c,r]
            next if cw.nil?
            # carry width in excess of max width of cells with min_colspan to cell in next col, subtracting hpadding
            if cw[COL_SPAN] > min_colspan
              widths[c+1,r] = [cw[COL_SPAN] - 1, [cw[COL_WIDTH] - max_width - @style.hpadding, 0].max]
            end
            cw[COL_WIDTH] = max_width
          end
        end

        result = 0
        grid.cols.times do |c|
          max_width = 0
          grid.rows.times do |r|
            if (widget = grid[c, r]) and (cw = widths[c, r])
              width = (0...cw[COL_SPAN]).inject((cw[COL_SPAN] - 1) * @style.hpadding) { |width, col_offset| width + widths[c+col_offset,r][COL_WIDTH] }
              max_width = [max_width, cw[COL_WIDTH]].max if cw[COL_SPAN] == 1
            end
          end
          result += max_width + @style.hpadding
        end
        result -= @style.hpadding if result > 0
        result
      end
    end
  end
end
