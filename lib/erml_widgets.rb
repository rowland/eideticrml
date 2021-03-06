#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

require 'erml_support'
require 'erml_styles'
require 'erml_rules'
require 'singleton'
require 'erml_widget_factories'

module EideticRML
  module Widgets
    class StdWidgetFactory < WidgetFactory
      include Singleton

      WidgetFactory.register_factory('std', self.instance)
    end

    class Widget
      include Support

      attr_reader :width_pct, :height_pct, :max_width_pct, :max_height_pct
      attr_accessor :parent, :disabled
      attr_writer :printed, :visible

      def initialize(parent, attrs={})
        @parent = parent
        @display = parent.display
        parent.children << self if parent.respond_to?(:children)
        attributes(attrs)
        @visible = true
      end

      def clone
        @clone ||= super
      end

      def initialize_copy(other)
        @is_clone = true
      end

      def attributes(attrs)
        attrs = attrs.inject({}) { |m, kv| m[kv.first.to_s.sub(/^class$/,'klass')] = kv.last; m } # stringify keys
        pre_keys, post_keys = attributes_first & attrs.keys, attributes_last & attrs.keys # keys are sorted same as attributes_first
        keys = attrs.keys - pre_keys - post_keys
        pre_keys.each { |key| attribute(key, attrs[key]) }
        keys.each { |key| attribute(key, attrs[key]) }
        post_keys.each { |key| attribute(key, attrs[key]) }
      end

      def align(value=nil)
        return @align if value.nil?
        @align = value.to_sym if [:top, :right, :bottom, :left].include?(value.to_sym)
      end

      def position(value=nil)
        return @position || :static if value.nil?
        @position = value.to_sym if [:static, :relative, :absolute].include?(value.to_sym)
      end

      def tag(value=nil)
        return @tag if value.nil?
        @tag = $1.freeze if value.to_s =~ /^(\w+)$/
        @path = nil
      end

      def id(value=nil)
        return @id if value.nil?
        if value.to_s =~ /^(\w+)$/
          @id = $1.freeze
          root.widgets[@id] = self
        end
        @path = nil
      end

      def klass(value=nil)
        return @klass if value.nil?
        @klass = $1.freeze if value.to_s =~ /^\s*(\w+(\s+\w+)*)\s*$/
        @path = nil
        return if parent.nil?
        attributes(root.rules.matching(path).inject({}) { |attrs, rule| attrs.update(rule.attrs) })
      end

      def selector_tag
        value = (tag || '').dup
        value << '#' << id unless id.nil?
        value << '.' << klass.split(/\s/).join('.') unless klass.nil?
        value
      end

      def path
        @path ||= (parent.nil? ? selector_tag : parent.path.dup << '/' << selector_tag).freeze
      end

      def left(value=nil, units=nil)
        return rel_x(shifted_x(@left || ((@right.nil? or width.nil?) ? nil : @right - width))) if value.nil?
        return to_units(value, left) if value.is_a?(Symbol)
        @position = :relative if position == :static and value.respond_to?(:to_str)
        @left = parse_measurement_pts(value, units || self.units)
        @left = parent.width + @left if @left < 0
        @width = @right - @left unless @right.nil?
      end

      def top(value=nil, units=nil)
        return rel_y(shifted_y(@top || ((@bottom.nil? or height.nil?) ? nil : @bottom - height))) if value.nil?
        return to_units(value, top) if value.is_a?(Symbol)
        @position = :relative if position == :static and value.respond_to?(:to_str)
        @top = parse_measurement_pts(value, units || self.units)
        @top = parent.height + @top if @top < 0
        @height = @bottom - @top unless @bottom.nil?
      end

      def right(value=nil, units=nil)
        return rel_y(shifted_x(@right || ((@left.nil? or width.nil?) ? nil : @left + width))) if value.nil?
        return to_units(value, right) if value.is_a?(Symbol)
        @position = :relative if position == :static and value.respond_to?(:to_str)
        @right = parse_measurement_pts(value, units || self.units)
        @right = parent.width + @right if @right <= 0
        @width = @right - @left unless @left.nil?
      end

      def bottom(value=nil, units=nil)
        return rel_y(shifted_y(@bottom || ((@top.nil? or height.nil?) ? nil : @top + height))) if value.nil?
        return to_units(value, bottom) if value.is_a?(Symbol)
        @position = :relative if position == :static and value.respond_to?(:to_str)
        @bottom = parse_measurement_pts(value, units || self.units)
        @bottom = parent.height + @bottom if @bottom <= 0
        @height = @bottom - @top unless @top.nil?
      end

      def shift(value=nil, units=nil)
        return [shift_x(units || :pt), shift_y(units || :pt)] if value.nil?
        if value.respond_to?(:to_str)
          x, y = value.to_s.split(',', 2)
        else
          x, y = Array(value)
        end
        @shift_x, @shift_y = parse_measurement_pts(x, units || self.units), parse_measurement_pts(y, units || self.units)
      end

      def has_height?
        @height and !@height_pct
      end

      def has_width?
        @width and !@width_pct
      end

      def preferred_width(writer, units=:pt)
        @width ? to_units(units, @width) : nil
      end

      def preferred_height(writer, units=:pt)
        @height ? to_units(units, @height) : nil
      end

      def width(value=nil, units=nil)
        return @width_pct ? @width_pct * parent.content_width : @width if value.nil?
        return to_units(value, width) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @width_pct = $1.to_f.quo(100)
          # @width = @width_pct * parent.content_width
          @width = nil
        elsif value.to_s =~ /^[+-]/
          @width = parent.content_width + parse_measurement_pts(value, units || self.units)
          @width_pct = nil
        else
          @width = parse_measurement_pts(value, units || self.units)
          @width_pct = nil
        end
        @right = nil unless @left.nil?
        width_set
      end

      def height(value=nil, units=nil)
        return @height_pct ? @height_pct * parent.content_height : @height if value.nil?
        return to_units(value, height) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @height_pct = $1.to_f.quo(100)
          @height = @height_pct * parent.content_height
        elsif value.to_s =~ /^[+-]/
          @height = parent.content_height + parse_measurement_pts(value, units || self.units)
          @height_pct = nil
        else
          @height = parse_measurement_pts(value, units || self.units)
          @height_pct = nil
        end
        @bottom = nil unless @top.nil?
        height_set
      end

      def max_width(value=nil, units=nil)
        return @max_width_pct ? @max_width_pct * parent.content_width : @max_width if value.nil?
        return to_units(value, max_width) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @max_width_pct = $1.to_f.quo(100)
          @max_width = @max_width_pct * parent.content_width
        elsif value.to_s =~ /^[+-]/
          @max_width = parent.content_width + parse_measurement_pts(value, units || self.units)
          @max_width_pct = nil
        else
          @max_width = parse_measurement_pts(value, units || self.units)
          @max_width_pct = nil
        end
      end

      def max_height(value=nil, units=nil)
        return @max_height_pct ? @max_height_pct * parent.content_height : @max_height if value.nil?
        return to_units(value, max_height) if value.is_a?(Symbol)
        if value =~ /(\d+(\.\d+)?)%/
          @max_height_pct = $1.to_f.quo(100)
          @max_height = @max_height_pct * parent.content_height
        elsif value.to_s =~ /^[+-]/
          @max_height = parent.content_height + parse_measurement_pts(value, units || self.units)
          @max_height_pct = nil
        else
          @max_height = parse_measurement_pts(value, units || self.units)
          @hmax_height_pct = nil
        end
      end

      def max_content_height
        max_height_avail - non_content_height
      end

      def max_height_avail
        height || parent.max_content_height - ((top || parent.content_top) - parent.content_top)
      end

      def content_top(units=:pt)
        to_units(units, top + margin_top + padding_top)
      end

      def content_right(units=:pt)
        to_units(units, right - margin_right - padding_right)
      end

      def content_bottom(units=:pt)
        to_units(units, bottom - margin_bottom - padding_bottom)
      end

      def content_left(units=:pt)
        to_units(units, left + margin_left + padding_left)
      end

      def content_height(units=:pt)
        to_units(units, (height || 0) - non_content_height)
      end

      def content_width(units=:pt)
        to_units(units, (width || 0) - non_content_width)
      end

      def non_content_height
        margin_top + padding_top + padding_bottom + margin_bottom
      end

      def non_content_width
        margin_left + padding_left + padding_right + margin_right
      end

      def before_layout
        @orig_width, @orig_height = @width, @height
      end

      def layout_widget(writer)
        # override this method
      end

      def after_layout
        # override this method
      end

      def units(value=nil)
        # inherited
        return @units || parent.units if value.nil?
        @units = value.to_sym if EideticPDF::UNIT_CONVERSION[value.to_sym]
      end

      def border(value=nil)
        return @border if value.nil?
        @border = pen_style_for(value)
        @border_top = @border_right = @border_bottom = @border_left = nil
      end

      def border_top(value=nil)
        return @border_top || @border if value.nil?
        @border_top = pen_style_for(value)
      end

      def border_right(value=nil)
        return @border_right || @border if value.nil?
        @border_right = pen_style_for(value)
      end

      def border_bottom(value=nil)
        return @border_bottom || @border if value.nil?
        @border_bottom = pen_style_for(value)
      end

      def border_left(value=nil)
        return @border_left || @border if value.nil?
        @border_left = pen_style_for(value)
      end

      def fill(value=nil)
        return @fill if value.nil?
        @fill = brush_style_for(value)
      end

      def margin_top(value=nil)
        return @margin_top || 0 if value.nil?
        return to_units(value, margin_top) if value.is_a?(Symbol)
        @margin_top = parse_measurement_pts(value, units)
      end

      def margin_right(value=nil)
        return @margin_right || 0 if value.nil?
        return to_units(value, margin_right) if value.is_a?(Symbol)
        @margin_right = parse_measurement_pts(value, units)
      end

      def margin_bottom(value=nil)
        return @margin_bottom || 0 if value.nil?
        return to_units(value, margin_bottom) if value.is_a?(Symbol)
        @margin_bottom = parse_measurement_pts(value, units)
      end

      def margin_left(value=nil)
        return @margin_left || 0 if value.nil?
        return to_units(value, margin_left) if value.is_a?(Symbol)
        @margin_left = parse_measurement_pts(value, units)
      end

      def margin(value=nil)
        return [margin_top, margin_right, margin_bottom, margin_left] if value.nil?
        return [margin_top(value), margin_right(value), margin_bottom(value), margin_left(value)] if value.is_a?(Symbol)
        if value.respond_to?(:to_str)
          value = value.split(',').map do |n|
            parse_measurement_pts(n, units)
          end
        else
          value = Array(value).map { |m| from_units(units, m) }
        end
        m = case value.size
          when 4 then value
          when 2 then value * 2
          when 1 then value * 4
        else nil
        end
        @margin_top, @margin_right, @margin_bottom, @margin_left = m unless m.nil?
      end

      def default_padding_top
        0
      end

      def default_padding_right
        0
      end

      def default_padding_bottom
        0
      end

      def default_padding_left
        0
      end

      def padding_top(value=nil)
        return @padding_top || default_padding_top if value.nil?
        return to_units(value, padding_top) if value.is_a?(Symbol)
        @padding_top = parse_measurement_pts(value, units)
      end

      def padding_right(value=nil)
        return @padding_right || default_padding_right if value.nil?
        return to_units(value, padding_right) if value.is_a?(Symbol)
        @padding_right = parse_measurement_pts(value, units)
      end

      def padding_bottom(value=nil)
        return @padding_bottom || default_padding_bottom if value.nil?
        return to_units(value, padding_bottom) if value.is_a?(Symbol)
        @padding_bottom = parse_measurement_pts(value, units)
      end

      def padding_left(value=nil)
        return @padding_left || default_padding_left if value.nil?
        return to_units(value, padding_left) if value.is_a?(Symbol)
        @padding_left = parse_measurement_pts(value, units)
      end

      def padding(value=nil)
        return [padding_top, padding_right, padding_bottom, padding_left] if value.nil?
        return [padding_top(value), padding_right(value), padding_bottom(value), padding_left(value)] if value.is_a?(Symbol)
        if value.respond_to?(:to_str)
          value = value.split(',').map do |n|
            parse_measurement_pts(n, units)
          end
        else
          value = Array(value).map { |p| from_units(units, p) }
        end
        p = case value.size
          when 4 then value
          when 2 then value * 2
          when 1 then value * 4
        else nil
        end
        @padding_top, @padding_right, @padding_bottom, @padding_left = p unless p.nil?
      end

      def font(value=nil)
        # inherited
        return @font || parent.font if value.nil?
        return @font = font.clone if value == :copy
        @font = font_style_for(value)
      end

      def font_color(value=nil)
        return font.color if value.nil?
        font(:copy).color(value)
      end

      def font_size(value=nil)
        return font.size if value.nil?
        font(:copy).size(value)
      end

      def font_style(value=nil)
        return font.style if value.nil?
        @font = font.clone
        @font.style(value)
      end

      def font_weight(value=nil)
        return font.weight if value.nil?
        @font = font.clone
        @font.weight(value)
      end

      def print(writer)
        # $stderr.puts "<<<try printing #{object_id} (#{tag}) visible: #{visible}"
        return if visible == false
        return if disabled
        # $stderr.puts "print #{tag} { left = #{left}, top = #{top}}"
        before_print(writer)
        if @rotate.nil?
          paint_background(writer)
          draw_content(writer)
          draw_border(writer)
        else
          writer.rotate(rotate, origin_x, origin_y) do
            paint_background(writer)
            draw_content(writer)
            draw_border(writer)
          end
        end
        @printed = true
        # $stderr.puts ">>>printed #{object_id} (#{tag})"
        @width = @orig_width if @orig_width
        @height = @orig_height if @orig_height
      rescue Exception => e
        raise RuntimeError, e.message + "\nError printing #{path}.", e.backtrace
      end

      def printed
        @printed or @disabled
      end

      def root
        parent.nil? ? self : parent.root
      end

      def root_page
        parent.root_page
      end

      def display(value=nil)
        return @display || :once if value.nil?
        @display = value.to_sym if [:once, :always, :first, :succeeding, :even, :odd].include?(value.to_sym)
      end

      def display_for_page(document_page_no, section_page_no)
        # puts "display_for_page: #{display.inspect}"
        case display
        when :always then true
        when :first then section_page_no == 1
        when :succeeding then section_page_no > 1
        when :even then document_page_no.even?
        when :odd then document_page_no.odd?
        else false
        end
      end

      def colspan(value=nil)
        return @colspan || 1 if value.nil?
        @colspan = value.to_i if value.to_i >= 1
      end

      def rowspan(value=nil)
        return @rowspan || 1 if value.nil?
        @rowspan = value.to_i if value.to_i >= 1
      end

      def origin_x(value=nil)
        if value.nil?
          case @origin_x
          when 'left'   then left
          when 'center' then (left + right).quo(2)
          when 'right'  then right
          else left
          end
        else
          @origin_x = value.strip
        end
      end

      def origin_y(value=nil)
        if value.nil?
          case @origin_y
          when 'top'    then top
          when 'middle' then (top + bottom).quo(2)
          when 'bottom' then bottom
          else top
          end
        else
          @origin_y = value.strip
        end
      end

      def rotate(value=nil)
        return @rotate if value.nil?
        @rotate = value.to_f
      end

      def z_index(value=nil)
        return @z_index || 0 if value.nil?
        @z_index = value.to_i
      end

      def visible(bounds=nil)
        return @visible if bounds.nil?
        return 0 if left.nil? or top.nil? or right.nil? or bottom.nil?
        (left >= bounds.left and top >= bounds.top and right <= bounds.right and bottom <= bounds.bottom) ? 1 : 0
      end

      # def postpone
      #   @visible = false
      #   @postponed ||= 0
      #   @postponed += 1
      #   @disabled = true if @postponed > 1
      # end

      def leaf?
        true
      end

      def leaves
        leaf? ? 1 : 0
      end

    protected
      def attribute(id, value)
        keys = id.to_s.split('.', 2)
        if keys.size == 1
          self.send(keys[0], value)
        else
          self.send(keys[0], :copy).send(keys[1], value)
        end
      rescue NoMethodError => e
        raise ArgumentError, "Unknown attribute #{id}", e.backtrace
      end

      def attributes_first
        @@attributes_first ||= %w(id tag class units position 
          left top width height right bottom 
          margin margin_top margin_right margin_bottom margin_left 
          padding padding_top padding_right padding_bottom padding_left 
          font border fill).freeze
      end

      def attributes_last
        @@attributes_last ||= %w(text).freeze
      end

      def before_print(writer)
        # override this method
      end

      def brush_style_for(id)
        bs = root.styles.for_id(id) || root.styles.for_id("brush_#{id}")
        bs = root.styles.add('brush', :id => "brush_#{id}", :color => id) if bs.nil? and EideticPDF::PdfK::NAMED_COLORS[id]
        raise ArgumentError, "Brush Style #{id} not found." unless bs.is_a?(Styles::BrushStyle)
        bs
      end

      def draw_border(writer, pen=nil)
        if pen
          pen.apply(writer)
          writer.rectangle(left + margin_left, top + margin_top,
            width - margin_left - margin_right, height - margin_top - margin_bottom)
        elsif [@border_top, @border_right, @border_bottom, @border_left].all? { |b| b.nil? }
          unless @border.nil?
            @border.apply(writer)
            writer.rectangle(left + margin_left, top + margin_top,
              width - margin_left - margin_right, height - margin_top - margin_bottom)
          end
        else
          unless @border_top.nil?
            @border_top.apply(writer)
            writer.move_to(left + margin_left, top + margin_top) # top left
            writer.line_to(right - margin_right, top + margin_top) # top right
          end
          unless @border_right.nil?
            @border_right.apply(writer)
            writer.move_to(right - margin_right, top + margin_top) # top right
            writer.line_to(right - margin_right, bottom - margin_bottom) # bottom right
          end
          unless @border_bottom.nil?
            @border_bottom.apply(writer)
            writer.move_to(right - margin_right, bottom - margin_bottom) # bottom right
            writer.line_to(left + margin_left, bottom - margin_bottom) # bottom left
          end
          unless @border_left.nil?
            @border_left.apply(writer)
            writer.move_to(left + margin_left, bottom - margin_bottom) # bottom left
            writer.line_to(left + margin_left, top + margin_top) # top left
          end
        end
      end

      def draw_content(writer)
        # override this method
      end

      def font_style_for(id)
        fs = root.styles.for_id(id)
        raise ArgumentError, "Font Style #{id} not found." unless fs.is_a?(Styles::FontStyle)
        fs
      end

      def height_set
        # override this callback
      end

      def paint_background(writer)
        unless @fill.nil?
          @fill.apply(writer)
          writer.rectangle(left + margin_left, top + margin_top,
            width - margin_left - margin_right, height - margin_top - margin_bottom,
            :fill => true, :border => false)
        end
      end

      def pen_style_for(id)
        ps = root.styles.for_id(id) || root.styles.for_id("pen_#{id}")
        ps = root.styles.add('pen', :id => "pen_#{id}", :pattern => 'solid', :color => id) if ps.nil? and EideticPDF::PdfK::NAMED_COLORS[id]
        raise ArgumentError, "Pen Style #{id} not found." unless ps.is_a?(Styles::PenStyle)
        ps
      end

      def shift_x(units=:pt)
        to_units(units, @shift_x || 0)
      end

      def shift_y(units=:pt)
        to_units(units, @shift_y || 0)
      end

      def shifted_x(value)
        value.nil? ? nil : shift_x + value
      end

      def shifted_y(value)
        value.nil? ? nil : shift_y + value
      end

      def rel_x(value)
        value.nil? ? nil : (position == :relative ? parent.left + value : value)
      end

      def rel_y(value)
        value.nil? ? nil : (position == :relative ? parent.top + value : value)
      end

      def widget_for(id)
        root.widgets[id]
      end

      def width_set
        # override this callback
      end
    end

    module HasLocation
      def x(value=nil)
        return @x if value.nil?
        return to_units(value, @x) if value.is_a?(Symbol)
        @position = :relative if position == :static and value.respond_to?(:to_str)
        @x = parse_measurement_pts(value, units)
        @x = parent.width - parent.margin_right + @x if @x < 0
      end

      def y(value=nil)
        return @y if value.nil?
        return to_units(value, @y) if value.is_a?(Symbol)
        @position = :relative if position == :static and value.respond_to?(:to_str)
        @y = parse_measurement_pts(value, units)
        @y = parent.height - parent.margin_bottom + @y if @y < 0
      end
    end

    module Shape
      include HasLocation

    protected
      def draw_border(writer)
        # suppress default behavior
        debug_pen_style = "debug_#{tag}_border"
        if root.styles.for_id(debug_pen_style)
          super(writer, pen_style_for(debug_pen_style))
        end
      end

      def paint_background(writer)
        # suppress default behavior
      end
    end

    class Arc < Widget
      StdWidgetFactory.instance.register_widget('arc', self)

      include Shape

      def r(value=nil)
        # TODO
      end

      def start_angle(value=nil)
        # TODO
      end

      def end_angle(value=nil)
        # TODO
      end

    protected
      def draw_content(writer)
        # TODO
      end
    end

    class Arch < Arc
      StdWidgetFactory.instance.register_widget('arc', self)

      undef_method :r

      def r1(value=nil)
        # TODO
      end

      def r2(value=nil)
        # TODO
      end

    protected
      def draw_content(writer)
        # TODO
      end
    end

    class Image < Widget
      StdWidgetFactory.instance.register_widget('image', self)

      def has_height?
        true
      end

      def has_width?
        true
      end

      def preferred_width(writer, units=:pt)
        if @width.nil? and @height
          w = @height * image(writer).width.quo(image(writer).height)
        else
          w = @width || image(writer).width
        end
        to_units(units, w)
      end

      def preferred_height(writer, units=:pt)
        if @height.nil? and @width
          # $stderr.puts "path A, width = #{@width}"
          h = @width * image(writer).height.quo(image(writer).width)
        else
          # $stderr.puts "path B"
          h = @height || image(writer).height
        end
        # $stderr.puts "h = #{h}"
        to_units(units, h)
      end

      def url(value=nil)
        return @url if value.nil?
        @url = value.to_s
      end

    protected
      def draw_content(writer)
        # $stderr.puts "print image: #{url}"
        writer.print_image_file(load_image(writer), left, top, width, height)
      end

      def image(writer)
        load_image(writer) if @image.nil?
        @image
      end

      def load_image(writer)
        raise Exception, "Image url must be specified." if url.nil?
        @image, @name = writer.load_image(url, stream) if @image.nil?
        url
      end

      def stream
        @stream ||= open(url, EideticPDF::ImageReadMode) { |io| io.read }
      end
    end

    class Line < Widget
      StdWidgetFactory.instance.register_widget('line', self)

      include Shape

      def angle(value=nil)
        return @angle || 0 if value.nil?
        @angle = value.to_f
      end

      def length(value=nil)
        # return @length || Math::sqrt(content_width ** 2 + content_height ** 2) if value.nil?
        return @length || calc_length if value.nil?
        return to_units(value, length) if value.is_a?(Symbol)
        @length = parse_measurement_pts(value, units)
      end

      def preferred_width(writer, units=:pt)
        w = @width || preferred_content_width + non_content_width
        to_units(units, w)
      end

      def preferred_height(writer, units=:pt)
        h = @height || preferred_content_height + non_content_height
        to_units(units, h)
      end

      def style(value=nil)
        return @style || pen_style_for('solid') if value.nil?
        @style = pen_style_for(value)
      end

    protected
      def calc_length
        return 0 if width.nil? or height.nil?
        l = Math::sqrt(content_width ** 2 + content_height ** 2)
        w = Math::cos(angle.degrees) * l
        h = Math::sin(angle.degrees) * l
        if w > content_width
          l *= content_width.quo(w)
        elsif h > content_height
          l *= content_height.quo(h)
        end
        l
      end

      def draw_content(writer)
        # puts "cw: #{content_width}, ch: #{content_height}"
        style.apply(writer)
        if position == :absolute
          raise Exception, "x and y must be set." unless @x and @y
          writer.line(@x, @y, angle, length)
        elsif position == :relative
          raise Exception, "x and y must be set." unless @x and @y
          writer.line(parent.content_left + @x, parent.content_top + @y, angle, length)
        else
          @x, @y = origin_for_quadrant(quadrant(angle))
          writer.line(@x, @y, angle, length)
        end
      end

      def origin_for_quadrant(quadrant)
        x_offset = (content_width - preferred_content_width).quo(2)
        y_offset = (content_height - preferred_content_height).quo(2)
        # puts "x_offset: #{x_offset}, y_offset: #{y_offset}"
        case quadrant
        when 1 then [content_left  + x_offset, content_bottom - y_offset]
        when 2 then [content_right - x_offset, content_bottom - y_offset]
        when 3 then [content_right - x_offset, content_top + y_offset]
        else        [content_left  + x_offset, content_top + y_offset]
        end
      end

      def preferred_content_width
        Math::cos(angle.degrees) * length
      end

      def preferred_content_height
        Math::sin(angle.degrees) * length
      end

      def quadrant(angle)
        a = angle % 360
        if a <= 90 then 1
        elsif a <= 180 then 2
        elsif a <= 270 then 3
        else 4
        end
      end
    end

    class Pie < Arc
      StdWidgetFactory.instance.register_widget('pie', self)

    protected
      def draw_content(writer)
        # TODO
      end
    end

    class Star < Widget
      StdWidgetFactory.instance.register_widget('star', self)

      include Shape

      def reverse(value=nil)
        # TODO
      end

      def rotation(value=nil)
        # TODO
      end

      def points(value=nil)
        # TODO
      end

      def r(value=nil)
        # TODO
      end

    protected
      def draw_content(writer)
        # TODO
      end
    end

    module Text
      def layout_widget(writer)
        super(writer)
        font.apply(writer)
      end

      def has_height?
        true
      end

      def has_width?
        !@width_pct
      end

      def strikeout(value=nil)
        return font.strikeout if value.nil?
        font(:copy).strikeout(value)
      end

      def underline(value=nil)
        return font.underline if value.nil?
        font(:copy).underline(value)
      end

      def line_height(value=nil)
        return font.line_height if value.nil?
        font(:copy).line_height(value)
      end

    protected
      def draw_content(writer)
        font.apply(writer)
      end
    end

    class Span < Widget
      StdWidgetFactory.instance.register_widget('span', self)

      include Text

      def initialize(parent, attrs={})
        raise ArgumentError, "Span must be child of Paragraph, Label or another Span." unless valid_parent?(parent)
        super(parent, attrs)
      end

      def printed
        true
      end

      def text(value=nil, font=nil)
        return super if value.nil?
        parent.text(value, font || self.font)
      end

    private
      def valid_parent?(parent)
        parent.is_a?(Span) or parent.is_a?(Paragraph) or parent.is_a?(Label)
      end
    end

    class PageNo < Span
      StdWidgetFactory.instance.register_widget('pageno', self)

      def initialize(parent, attrs={})
        super(parent, attrs)
        parent.text(self)
      end

      def before_layout
        super
        root.document_page_no = @new_page_no if @new_page_no
      end

      def text(value=nil)
        return root.document_page_no.to_s if value.nil?
        @new_page_no = value.to_i
      end

      def to_s
        text
      end
    end

    class PreformattedText < Widget
      StdWidgetFactory.instance.register_widget('pre', self)

      include Text

      def initialize(parent, attrs={})
        @lines = []
        super(parent, attrs)
        font('fixed') if @font.nil?
      end

      def text(value=nil)
        return @lines if value.nil?
        value.lstrip! if @lines.empty?
        @lines.concat(value.split("\n")) unless value.empty?
      end

      def layout_widget(writer)
        super(writer)
        @lines.pop while @lines.last.strip.empty?
        @height ||= preferred_height(writer)
      end

      def preferred_width(writer, units=:pt)
        font.apply(writer)
        @preferred_width = @width || @lines.map { |line| writer.width(line) }.max + non_content_width
        to_units(units, @preferred_width)
      end

      def preferred_height(writer, units=:pt)
        font.apply(writer)
        @preferred_height = writer.height(@lines) + non_content_height - (writer.height - writer.height.quo(writer.line_height))
        to_units(units, @preferred_height)
      end

      def url(value=nil)
        return @url if value.nil?
        @url = value
        text(text_for(@url))
      end

    protected
      def draw_content(writer)
        raise Exception, "left & top must be set: #{text.inspect}" if left.nil? or top.nil?
        font.apply(writer)
        writer.puts_xy(content_left, content_top + writer.text_ascent, @lines)
      end

      def text_for(url)
        open(url) { |f| f.read }
      rescue Exception => e
        raise RuntimeError, "Error opening #{url}", e.backtrace
      end
    end

    class Container < Widget
      StdWidgetFactory.instance.register_widget('div', self)

      attr_reader :children

      def initialize(parent, attrs={})
        super(parent, attrs)
        @children = []
      end

      def initialize_copy(other)
        super(other)
        @children = other.children.map { |child| child.clone }
        @children.each { |child| child.parent = self }
      end

      def after_layout
        # puts "after_layout: #{tag}"
        layout.manager.after_layout(self) unless layout.nil?
        children.each do |widget|
          widget.after_layout if widget.visible
        end
      end

      def cols(value=nil)
        return @cols if value.nil?
        @cols = value.to_i if value.to_i > 0
      end

      def layout(value=nil)
        return @layout_style || layout('vbox') if value.nil?
        @layout_style = layout_style_for(value)
      end

      def layout_container(writer)
        layout.manager.layout(self, writer)
        # returns count
      end

      def layout_widget(writer)
        super(writer)
        layout_container(writer)
      end

      def leaf?
        children.empty?
      end

      def leaves
        visible ? children.select { |w| w.visible }.inject(0) { |m, widget| m + widget.leaves } + super : 0
      end

      def more(flag=nil)
        parent.more(flag)
      end

      def order(value=nil)
        return @order || :rows if value.nil?
        @order = value.to_sym if [:rows, :cols].include?(value.to_sym)
      end

      def overflow(value=nil)
        return @overflow if value.nil?
        @overflow = case value
          when true, 'true' then true
          when false, 'false' then false
          else value.to_s
        end
      end

      def paragraph_style(value=nil)
        return @paragraph_style || parent.paragraph_style if value.nil?
        @paragraph_style = paragraph_style_for(value)
      end

      def preferred_content_height(writer)
        @preferred_content_height ||= layout.manager.preferred_height(layout_grid, writer)
      end

      def preferred_content_width(writer)
        @preferred_content_width ||= layout.manager.preferred_width(layout_grid, writer)
      end

      def preferred_height(writer, units=:pt)
        @preferred_height ||= @height || (preferred_content_height(writer) || return) + non_content_height
        to_units(units, overflow ? [@preferred_height, max_height_avail].min : @preferred_height)
      end

      def preferred_width(writer, units=:pt)
        @preferred_width ||= @width || (preferred_content_width(writer) || return) + non_content_width
        to_units(units, @preferred_width)
      end

      def printed
        disabled or (super and children.all? { |widget| widget.printed })
      end

      def rows(value=nil)
        return @rows if value.nil?
        @rows = value.to_i if value.to_i > 0
      end

      def source(id=nil)
        return children if id.nil?
        @children = widget_for(id).children
      end

      def visible(bounds=nil)
        bounds.nil? ? super : super + children.inject(0) { |total, widget| total + widget.visible(bounds) }
      end

    protected
      def draw_content(writer)
        super(writer)
        children.sort { |a, b| a.z_index <=> b.z_index }.each { |child| child.print(writer) }
      end

      def layout_grid
        @layout_grid ||= layout.manager.grid(self)
      end

      def layout_style_for(id)
        ls = root.styles.for_id(id)
        raise ArgumentError, "Layout Style #{id} not found." unless ls.is_a?(Styles::LayoutStyle)
        ls
      end

      def paragraph_style_for(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Paragraph Style #{id} not found." unless ps.is_a?(Styles::ParagraphStyle)
        ps
      end
    end

    class Circle < Container
      StdWidgetFactory.instance.register_widget('circle', self)

      include Shape

      def before_layout
        super
        @width ||= @height
        @height ||= @width
      end

      def clip(value=nil)
        # TODO
      end

      def default_padding_top
        (@preferred_height and @preferred_content_height) ? @preferred_radius - @preferred_content_height / 2.0 : 0
      end

      def default_padding_right
        (@preferred_width and @preferred_content_width) ? @preferred_radius - @preferred_content_width / 2.0 : 0
      end

      def default_padding_bottom
        (@preferred_height and @preferred_content_height) ? @preferred_radius - @preferred_content_height / 2.0 : 0
      end

      def default_padding_left
        (@preferred_width and @preferred_content_width) ? @preferred_radius - @preferred_content_width / 2.0 : 0
      end

      def preferred_radius(writer, units=:pt)
        @preferred_radius ||= begin
          pcw, pch = preferred_content_width(writer), preferred_content_height(writer)
          return if pcw.nil? and pch.nil?
          Math.sqrt(((pcw || pch) / 2.0) ** 2 + ((pch || pcw) / 2.0) ** 2)
        end
        to_units(units, @preferred_radius)
      end

      def preferred_height(writer, units=:pt)
        @preferred_height ||= @height || @width || ((preferred_radius(writer) || return) * 2 + non_content_height)
        to_units(units, @preferred_height)
      end

      def preferred_width(writer, units=:pt)
        @preferred_width ||= @width || @height || ((preferred_radius(writer) || return) * 2 + non_content_width)
        to_units(units, @preferred_width)
      end

      def r(value=nil, units=nil)
        return @r if value.nil?
        return to_units(value, @r) if value.is_a?(Symbol)
        @r = parse_measurement_pts(value, units || self.units)
        @r = [(width - margin_left - margin_right).quo(2), (height - margin_top - margin_bottom).quo(2)].min + @r if @r < 0
        @width ||= @r * 2 + margin_left + margin_right
        @height ||= @r * 2 + margin_top + margin_bottom
      end

      def reverse(value=nil)
        # TODO
      end

    protected
      def before_print(writer)
        # puts "left: #{left}, margin_left: #{margin_left}, right: #{right}, margin_right: #{margin_right}"
        @x ||= (left + margin_left + right - margin_right).quo(2)
        @y ||= (top + margin_top + bottom - margin_bottom).quo(2)
        # puts "before_print 1 @r: #{@r.inspect}"
        # puts "@r ||= [(#{width} - #{margin_left} - #{margin_right}).quo(2), (#{height} - #{margin_top} - #{margin_bottom}).quo(2)].min"
        @r ||= [(width - margin_left - margin_right).quo(2), (height - margin_top - margin_bottom).quo(2)].min
        # @r ||= preferred_radius(writer)
        # @width ||= @r * 2 + margin_left + margin_right
        # @height ||= @r * 2 + margin_top + margin_bottom
        # puts "before_print 2 @r: #{@r.inspect}"
        super(writer)
      end

      def height_set
        @preferred_height ||= @height
        @preferred_width ||= @height
      end

      def width_set
        @preferred_width ||= @width
        @preferred_height ||= @width
      end

      def x_offset
        (position == :relative) ? parent.content_left : 0
      end

      def y_offset
        (position == :relative) ? parent.content_top : 0
      end

      def draw_content(writer)
        super(writer)
        options = {}
        options[:border] = !!@border
        options[:fill] = !!@fill
        @border.apply(writer) unless @border.nil?
        @fill.apply(writer) unless @fill.nil?
        # puts "writer.circle(#{@x} + #{x_offset}, #{@y} + #{y_offset}, #{r}, #{options.inspect})"
        writer.circle(@x + x_offset, @y + y_offset, r, options)
      end
    end

    class Ellipse < Container
      StdWidgetFactory.instance.register_widget('ellipse', self)

      include Shape

      def rotation(value=nil)
        # TODO
      end

      def rx(value=nil)
        return @rx if value.nil?
        return to_units(value, @rx) if value.is_a?(Symbol)
        @rx = parse_measurement_pts(value, units || self.units)
        @rx = (width - margin_left - margin_right).quo(2) + @rx if @rx < 0
        @width ||= @rx * 2 + margin_left + margin_right
      end

      def ry(value=nil)
        return @ry if value.nil?
        return to_units(value, @ry) if value.is_a?(Symbol)
        @ry = parse_measurement_pts(value, units || self.units)
        @ry = (height - margin_top - margin_bottom).quo(2) + @ry if @ry < 0
        @height ||= @ry * 2 + margin_top + margin_bottom
      end

    protected
      def draw_content(writer)
        @x ||= (content_left + content_right).quo(2)
        @y ||= (content_top + content_bottom).quo(2)
        @rx ||= (width - margin_left - margin_right).quo(2)
        @ry ||= (height - margin_top - margin_bottom).quo(2)
        options = {}
        options[:border] = !!@border
        options[:fill] = !!@fill
        @border.apply(writer) unless @border.nil?
        @fill.apply(writer) unless @fill.nil?
        x_offset, y_offset = (position == :relative) ? [parent.content_left, parent.content_top] : [0, 0]
        writer.ellipse(@x + x_offset, @y + y_offset, @rx, @ry, options)
        super(writer)
      end
    end

    class Label < Container
      StdWidgetFactory.instance.register_widget('label', self)

      include HasLocation
      include Text

      def angle(value=nil)
        return style.angle if value.nil?
        style(:copy).angle(value)
      end

      def before_layout
        children.each { |child| child.before_layout }
      end

      def layout_container(writer)
        # suppress default behavior
        0
      end

      def preferred_width(writer, units=:pt)
        font.apply(writer)
        to_units(units, writer.width(text) + non_content_width)
      end

      def preferred_height(writer, units=:pt)
        font.apply(writer)
        to_units(units, writer.text_height + non_content_height)
      end

      def style(value=nil)
        return @style ||= label_style_for('label') if value.nil?
        return @style = style.clone if value == :copy
        @style = label_style_for(value)
      end

      def text(value=nil)
        @text_pieces ||= []
        return @text_pieces.join if value.nil?
        value.lstrip! if @text_pieces.empty? and value.respond_to?(:lstrip!)
        @text_pieces << value unless value.respond_to?(:empty?) and value.empty?
      end

      def text_align(value=nil)
        return style.text_align if value.nil?
        style(:copy).text_align(value)
      end

    protected
      def before_print(writer)
        @width ||= preferred_width(writer)
        @height ||= preferred_height(writer)
        super(writer)
      end

      def draw_content(writer)
        super(writer)
        options = { :angle => angle, :underline => underline }
        @y ||= content_top
        case text_align
        when :left
          @x ||= content_left
        when :center
          @x ||= (content_left + content_right).quo(2)
          options[:align] = :center
        when :right
          @x ||= content_right
          options[:align] = :right
        end
        writer.print_xy(@x, @y + writer.text_ascent, text, options)
      end

      def label_style_for(id)
        ls = root.styles.for_id(id)
        raise ArgumentError, "Label Style #{id} not found." unless ls.is_a?(Styles::LabelStyle)
        ls
      end
    end

    class Paragraph < Container
      StdWidgetFactory.instance.register_widget('p', self)

      include Text

      def before_layout
        children.each { |child| child.before_layout }
      end

      def bullet(value=nil)
        return @bullet.nil? ? style.bullet : @bullet if value.nil?
        @bullet = bullet_style_for(value)
      end

      def layout_container(writer)
        # suppress default behavior
        0
      end

      def layout_widget(writer)
        super(writer)
        @height ||= preferred_height(writer)
      end

      def preferred_width(writer, units=:pt)
        @preferred_width = @width || begin
          (rich_text(writer).width(root_page.width - bullet_width - non_content_width) || 0) + bullet_width + non_content_width + 1
        end
        to_units(units, @preferred_width)
      end

      def preferred_height(writer, units=:pt)
        @preferred_height = @height || begin
          ph = if width.nil?
            rich_text(writer).height(parent.content_width - bullet_width - non_content_width) * line_height
          else
            rich_text(writer).height(content_width - bullet_width) * line_height
          end
          @preferred_height = ph + non_content_height - rich_text(writer).height * (line_height - 1)
        end
        to_units(units, @preferred_height)
      end

      def style(value=nil)
        # inherited
        return @style || parent.paragraph_style if value.nil?
        return @style || @style = parent.paragraph_style.clone if value == :copy
        @style = paragraph_style_for(value)
      end

      def text(value=nil, font=nil)
        return @text_pieces if value.nil?
        value.gsub!(/\n\s*/, ' ') if value.respond_to?(:gsub!)
        @text_pieces ||= []
        value.lstrip! if @text_pieces.empty? and value.respond_to?(:lstrip!)
        @text_pieces << [value, font || self.font] unless value.respond_to?(:empty?) and value.empty?
      end

      def text_align(value=nil)
        return style.text_align if value.nil?
        @style = style.clone
        @style.text_align(value)
      end

    protected
      def bullet_style_for(id)
        bs = root.styles.for_id(id)
        raise ArgumentError, "Bullet Style #{value} not found." unless bs.is_a?(Styles::BulletStyle)
        bs
      end

      def bullet_width
        bullet.nil? ? 0 : bullet.width
      end

      def draw_content(writer)
        super(writer)
        options = { :align => style.text_align, :underline => underline, :width => content_width }
        unless bullet.nil?
          bullet.apply(writer)
          options[:bullet] = bullet.id unless bullet.nil?
        end
        pen_style_for('solid').apply(writer)
        raise Exception, "left & top must be set: #{text.inspect}" if left.nil? or top.nil?
        writer.paragraph_xy(content_left, content_top + rich_text(writer).ascent(content_width), rich_text(writer), options)
        @rich_text = nil
      end

      def paragraph_style_for(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Paragraph Style #{id} not found." unless ps.is_a?(Styles::ParagraphStyle)
        ps
      end

      def rich_text(writer)
        if @rich_text.nil?
          @text_pieces ||= []
          # Trim trailing whitespace.
          while !@text_pieces.empty? and @text_pieces.last[0].respond_to?(:to_str) and @text_pieces.last[0].rstrip!
            @text_pieces.pop if @text_pieces.last[0].empty?
          end
          @rich_text = EideticPDF::PdfText::RichText.new
          @text_pieces.each do |piece|
            text, font = piece
            font.apply(writer)
            @rich_text.add(text.to_s, writer.font, :color => font.color, :underline => font.underline)
          end unless @text_pieces.nil?
        end
        @rich_text
      end
    end

    class Polygon < Container
      StdWidgetFactory.instance.register_widget('polygon', self)

      include Shape

      def clip(value=nil)
        # TODO
      end

      def r(value=nil)
        return @r if value.nil?
        return to_units(value, @r) if value.is_a?(Symbol)
        @r = parse_measurement_pts(value, units || self.units)
        @r = [(width - margin_left - margin_right).quo(2), (height - margin_top - margin_bottom).quo(2)].min + @r if @r < 0
        @width ||= @r * 2 + margin_left + margin_right
        @height ||= @r * 2 + margin_top + margin_bottom
      end

      def reverse(value=nil)
        # TODO
      end

      def rotation(value=nil)
        return @rotation if value.nil?
        @rotation = value.to_f
      end

      def sides(value=nil)
        return @sides || 3 if value.nil?
        @sides = value.to_i if value.to_i >= 3
      end

    protected
      def draw_content(writer)
        @x ||= (content_left + content_right).quo(2)
        @y ||= (content_top + content_bottom).quo(2)
        @r ||= [(width - margin_left - margin_right).quo(2), (height - margin_top - margin_bottom).quo(2)].min
        options = {}
        options[:border] = !!@border
        options[:fill] = !!@fill
        options[:rotation] = @rotation
        @border.apply(writer) unless @border.nil?
        @fill.apply(writer) unless @fill.nil?
        x_offset, y_offset = (position == :relative) ? [parent.content_left, parent.content_top] : [0, 0]
        writer.polygon(@x + x_offset, @y + y_offset, @r, sides, options)
        super(writer)
      end
    end

    class Rectangle < Container
      StdWidgetFactory.instance.register_widget('rect', self)

      include Shape

      def clip(value=nil)
        # TODO
      end

      def corners(value=nil)
        return @corners if value.nil?
        value = value.split(',') if value.respond_to?(:to_str)
        value = Array(value)
        @corners = value.map { |n| parse_measurement_pts(n, units) } if [1,2,4,8].include?(value.size)
      end

      # def path(value=nil)
      #   # TODO
      # end

      def reverse(value=nil)
        # TODO
      end

    protected
      def draw_content(writer)
        raise Exception, "left, top, width & height must be set" if [left, top, width, height].any? { |value| value.nil? }
        options = {}
        options[:corners] = @corners unless @corners.nil?
        options[:border] = !!@border
        options[:fill] = !!@fill
        @border.apply(writer) unless @border.nil?
        @fill.apply(writer) unless @fill.nil?
        writer.rectangle(left + margin_left, top + margin_top, 
          width - margin_left - margin_right, height - margin_top - margin_bottom, 
          options)
        super(writer)
      end
    end

    class Page < Container
      StdWidgetFactory.instance.register_widget('page', self)

      def initialize(parent, attrs={})
        @default_margin = true
        @more = true
        @overflow = true
        super(parent, attrs)
        raise ArgumentError, "Page must be child of Document." unless parent.nil? or parent.is_a?(Document)
      end

      def bottom(units=:pt)
        height(units)
      end

      def compress(value=nil)
        # TODO
      end

      def crop(value=nil)
        # inherited
        # TODO
      end

      def height(units=:pt)
        to_units(units, style.height)
      end

      def left(units=:pt)
        0
      end

      def margin(value=nil)
        # inherited
        return @default_margin ? parent.margin(value) : super(value) if value.nil? or value.is_a?(Symbol)
        super(value)
        @default_margin = false
      end

      def margin_top(value=nil)
        # inherited
        return @default_margin ? parent.margin_top(value) : super(value) if value.nil? or value.is_a?(Symbol)
        super(value)
        @default_margin = false
      end

      def margin_right(value=nil)
        # inherited
        return @default_margin ? parent.margin_right(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margin(margin) if @default_margin
        super(value)
        @default_margin = false
      end

      def margin_bottom(value=nil)
        # inherited
        return @default_margin ? parent.margin_bottom(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margin(margin) if @default_margin
        super(value)
        @default_margin = false
      end

      def margin_left(value=nil)
        # inherited
        return @default_margin ? parent.margin_left(value) : super(value) if value.nil? or value.is_a?(Symbol)
        margin(margin) if @default_margin
        super(value)
        @default_margin = false
      end

      def more(flag=nil)
        return @more if flag.nil?
        @more = flag
      end

      def orientation(value=nil)
        # inherited
        return style.orientation if value.nil?
        style(:copy).orientation(value)
      end

      def positioned_widgets
        @positioned_widgets ||= Hash.new(0)
      end

      def print(writer)
        root.section_page_no = 0
        while more
          more(false)
          writer.open_page(:page_size => size, :orientation => orientation)
          root.document_page_no += 1
          root.section_page_no += 1
          positioned_widgets.clear
          # $stderr.puts "----before layout widget"
          layout_widget(writer)
          # after_layout
          # $stderr.puts "----before super print"
          super(writer)
          # $stderr.puts "----after super print"
          writer.close_page
          break if positioned_widgets[:static] == 0
        end
      end

      def right(units=:pt)
        width(units)
      end

      def root_page
        self
      end

      def rotate(value=nil)
        # inherited
        # TODO
      end

      def size(value=nil)
        # inherited
        return style.size if value.nil?
        style(:copy).size(value)
      end

      def style(value=nil)
        # inherited
        return @page_style || parent.page_style if value.nil?
        return @page_style || @page_style = parent.page_style.clone if value == :copy
        @page_style = page_style_for(value)
      end

      def top(units=:pt)
        0
      end

      def width(units=:pt)
        to_units(units, style.width)
      end

    protected
      def page_style_for(id)
        ps = root.styles.for_id(id)
        raise ArgumentError, "Page Style #{id} not found." unless ps.is_a?(Styles::PageStyle)
        ps
      end
    end

    class Document < Page
      StdWidgetFactory.instance.register_widget('erml', self)

      alias :pages :children
      attr_accessor :document_page_no, :section_page_no

      def initialize(parent=nil, attrs={})
        super(parent, attrs)
        @default_margin = false
        init_default_styles
      end

      # def orientation(value=nil)
      #   return @orientation || :portrait if value.nil?
      #   super(value)
      # end

      def rules
        @rules ||= Rules::RuleCollection.new
      end

      def page_style(value=nil)
        return @page_style if value.nil?
        super(value)
      end

      def pages_up(value=nil)
        return @pages_up || [1, 1] if value.nil?
        if value.respond_to?(:to_str)
          x, y = value.to_s.split(',', 2)
        else
          x, y = Array(value)
        end
        @pages_up = [x.to_i, y.to_i]
      end

      def pages_up_layout(value=nil)
        return @pages_up_layout || :across if value.nil?
        @pages_up_layout = value.to_sym if [:across, :down].include?(value.to_sym)
      end

      def print(writer)
        @document_page_no = 0
        writer.open(:v_text_align => :base, :pages_up => pages_up, :pages_up_layout => pages_up_layout, :orientation => orientation, :text_encoding => 'UTF-8')
        pages.each do |page|
          page.print(writer)
        end
        writer.close
      end

      def styles
        @styles ||= Styles::StyleCollection.new
      end

      def to_s
        writer = EideticPDF::DocumentWriter.new
        print(writer)
        writer.to_s
      end

      def units(value=nil)
        return @units || :pt if value.nil?
        super(value)
      end

      def widgets
        @widgets ||= {}
      end

    private
      def init_default_styles
        @page_style = styles.add('page', :id => 'page')
        @font = styles.add('font', :id => 'font')
        @label_style = styles.add('label', :id => 'label')
        @paragraph_style = styles.add('para', :id => 'p')
        styles.add('layout', :id => 'absolute', :manager => 'absolute')
        styles.add('layout', :id => 'flow',     :manager => 'flow', :padding => 5)
        styles.add('layout', :id => 'hbox',     :manager => 'hbox')
        styles.add('layout', :id => 'vbox',     :manager => 'vbox')
        styles.add('layout', :id => 'table',    :manager => 'table', :padding => 5)
        styles.add('pen', :id => 'solid',  :pattern => 'solid',  :color => 'Black')
        styles.add('pen', :id => 'dotted', :pattern => 'dotted', :color => 'Black')
        styles.add('pen', :id => 'dashed', :pattern => 'dashed', :color => 'Black')
        styles.add('font', :id => 'fixed', :name => 'Courier', :size => 10)
      end
    end
  end
end
