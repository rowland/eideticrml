#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-16.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require 'test/unit'
require File.join(File.dirname(__FILE__), 'test_helpers')
require 'erml_widgets'
require 'erml_styles'

include EideticRML::Widgets
include EideticRML::Styles

class StdWidgetFactoryTestCases < Test::Unit::TestCase
  def test_for_namespace
    assert_equal(StdWidgetFactory.instance, WidgetFactory.for_namespace('std'))
  end
end

class WidgetTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @alt = @doc.styles.add('font', :id => 'alt', :name => 'Times', :size => 10, :style => 'Bold', :encoding => 'CP1252', :color => '0xFFFFFF')
    @blue_dash = @doc.styles.add('pen', :id => 'blue_dash', :color => 'Blue', :width => '4pt', :pattern => 'dashed')
    @dotted = @doc.styles.for_id('dotted')
    @page = StdWidgetFactory.instance.make_widget('page', @doc)
    @widget = Widget.new(@page)
  end

  def test_initialize
    assert_not_nil(@widget)
    assert_equal(@page, @widget.parent)
  end

  def test_align
    assert_nil(@widget.align)
    [:top, :right, :bottom, :left].each do |align|
      @widget.align(align)
      assert_equal(align, @widget.align)
    end
    @widget.align(:bogus)
    assert_equal(:left, @widget.align) # unchanged
  end

  def test_position
    assert_equal(:static, @widget.position)

    @widget.position(:relative)
    assert_equal(:relative, @widget.position)
    @widget.position(:absolute)
    assert_equal(:absolute, @widget.position)

    @widget.position("static")
    assert_equal(:static, @widget.position)
    @widget.position("relative")
    assert_equal(:relative, @widget.position)
    @widget.position("absolute")
    assert_equal(:absolute, @widget.position)
  end

  def test_tag
    assert_nil(@widget.tag)
    @widget.tag(' !@#$%')
    assert_nil(@widget.tag) # unchanged
    @widget.tag('widget')
    assert_equal('widget', @widget.tag)
  end

  def test_top
    assert_equal(:static, @widget.position)

    @widget.top(18)
    assert_equal(18, @widget.top)
    assert_equal(0.25, @widget.top(:in))
    assert_equal(:relative, @widget.position)

    @widget.height("7in")
    assert_equal(7.25, @widget.bottom(:in))

    @widget.top("-2in")
    assert_equal(9, @widget.top(:in))
  end

  def test_right
    assert_equal(:static, @widget.position)

    @widget.right(36)
    assert_equal(36, @widget.right)
    assert_equal(0.5, @widget.right(:in))
    assert_equal(:relative, @widget.position)

    @widget.right(342)
    @widget.width(1, :in)
    assert_equal(4.75, @widget.right(:in))
    assert_equal(3.75, @widget.left(:in))

    @widget.right("-1in")
    assert_equal(6.5, @widget.left(:in))
  end

  def test_bottom
    assert_equal(:static, @widget.position)

    @widget.bottom(54)
    assert_equal(54, @widget.bottom)
    assert_equal(0.75, @widget.bottom(:in))
    assert_equal(:relative, @widget.position)

    @widget.height(36)
    assert_equal(18, @widget.top)

    @widget.bottom("-144")
    @widget.height("72")
    assert_equal(576, @widget.top)
    assert_equal(8, @widget.top(:in))
  end

  def test_left
    assert_equal(:static, @widget.position)

    @widget.left(72)
    assert_equal(72, @widget.left)
    assert_equal(1, @widget.left(:in))
    assert_equal(:relative, @widget.position)

    @widget.width("7in")
    assert_equal(8, @widget.right(:in))

    @widget.left("-2in")
    assert_equal(6.5, @widget.left(:in))
  end

  def test_units
    assert_equal(:pt, @doc.units)
    assert_equal(:pt, @widget.units) # inherited
    @widget.units(:in)
    assert_equal(:in, @widget.units)
    assert_equal(:pt, @doc.units) # unchanged
  end

  def assert_font_defaults(f)
    assert_not_nil(f)
    assert_equal('Helvetica', f.name)
    assert_equal(12, f.size)
    assert_equal('', f.style)
    assert_equal('Type1', f.sub_type)
    assert_equal('WinAnsiEncoding', f.encoding)
    assert_equal(0, f.color)
  end

  def test_font
    assert_font_defaults(@doc.font)
    assert_font_defaults(@widget.font) # same as parent
    @widget.font('alt')
    assert_equal(@alt, @widget.font)
    assert_font_defaults(@doc.font) # unchanged
  end

  def test_font_copy
    assert_font_defaults(@doc.font)
    assert_font_defaults(@widget.font) # same as parent
    @widget.font(:copy).size(20)
    assert_equal(20, @widget.font.size)
    assert_not_equal(@alt, @widget.font)
    assert_font_defaults(@doc.font) # unchanged
  end

  def test_font_style
    @widget.font_style('Bold')
    assert_equal('Bold', @widget.font.style)
    assert_font_defaults(@doc.font) # unchanged
  end

  def test_width_fixed
    @page.units(:in)
    assert_nil(@widget.width)
    @widget.width('5')
    assert_equal(5, @widget.width(:in))
    assert_equal(360, @widget.width)
  end

  def test_width_percent
    @page.units(:in)
    assert_nil(@widget.width)
    @widget.width('50%')
    assert_equal(0.5, @widget.width_pct)
    assert_equal(4.25, @widget.width(:in))
    assert_equal(306, @widget.width)
  end

  def test_width_relative
    @page.margin('1in')
    assert_nil(@widget.width)
    @widget.width('-2in')
    assert_equal(4.5, @widget.width(:in))
    assert_equal(324, @widget.width)
    @widget.width('+1in')
    assert_equal(7.5, @widget.width(:in))
    assert_equal(540, @widget.width)
  end

  def test_height_fixed
    @page.units(:in)
    assert_nil(@widget.height)
    @widget.height('3.5')
    assert_equal(3.5, @widget.height(:in))
    assert_equal(252, @widget.height)
  end

  def test_height_percent
    @page.units(:in)
    assert_nil(@widget.height)
    @widget.height('50%')
    assert_equal(0.5, @widget.height_pct)
    assert_equal(5.5, @widget.height(:in))
    assert_equal(396, @widget.height)
  end

  def test_height_relative
    @page.margin('1in')
    assert_nil(@widget.height)
    @widget.height('-2in')
    assert_equal(7, @widget.height(:in))
    assert_equal(504, @widget.height)
    @widget.height('+1in')
    assert_equal(10, @widget.height(:in))
    assert_equal(720, @widget.height)
  end

  def test_content_top
    @widget.top(50)
    assert_equal(50, @widget.content_top)
    @widget.padding(10)
    assert_equal(60, @widget.content_top)
    @widget.margin(5)
    assert_equal(65, @widget.content_top)
  end

  def test_content_right
    @widget.right(50)
    assert_equal(50, @widget.content_right)
    @widget.padding(10)
    assert_equal(40, @widget.content_right)
    @widget.margin(5)
    assert_equal(35, @widget.content_right)
  end

  def test_content_bottom
    @widget.bottom(50)
    assert_equal(50, @widget.content_bottom)
    @widget.padding(10)
    assert_equal(40, @widget.content_bottom)
    @widget.margin(5)
    assert_equal(35, @widget.content_bottom)
  end

  def test_content_left
    @widget.left(50)
    assert_equal(50, @widget.content_left)
    @widget.padding(10)
    assert_equal(60, @widget.content_left)
    @widget.margin(5)
    assert_equal(65, @widget.content_left)
  end

  def test_content_width
    assert_equal(0, @widget.content_width)
    @widget.width('36')
    assert_equal(36, @widget.content_width) # same as width unless overridden
    assert_equal(0.5, @widget.content_width(:in)) # in specified units
    @widget.margin([1,2,3,4])
    assert_equal(30, @widget.content_width)
    @widget.padding([4,3,2,1])
    assert_equal(26, @widget.content_width)
  end

  def test_content_height
    # assert_nil(instance)
    assert_equal(0, @widget.content_height)
    @widget.height('3.5in')
    assert_equal(252, @widget.content_height) # same as height unless overridden
    assert_equal(3.5, @widget.content_height(:in)) # in specified units
    @widget.margin([1,2,3,4])
    assert_equal(248, @widget.content_height)
    @widget.padding([4,3,2,1])
    assert_equal(242, @widget.content_height)
  end

  def test_border
    assert_nil(@widget.border)
    @widget.border('blue_dash')
    assert_not_nil(@widget.border)
    assert_equal('blue_dash', @widget.border.id)
    assert_equal('Blue', @widget.border.color)
    assert_equal(4, @widget.border.width)
    assert_equal(:pt, @widget.border.units)
  end

  def test_border_top
    assert_nil(@widget.border_top)
    @widget.border_top('blue_dash')
    assert_equal(@blue_dash, @widget.border_top)
    @widget.border('dotted')
    assert_equal(@dotted, @widget.border_top)
  end

  def test_border_right
    assert_nil(@widget.border_right)
    @widget.border_right('blue_dash')
    assert_equal(@blue_dash, @widget.border_right)
    @widget.border('dotted')
    assert_equal(@dotted, @widget.border_right)
  end

  def test_border_bottom
    assert_nil(@widget.border_bottom)
    @widget.border_bottom('blue_dash')
    assert_equal(@blue_dash, @widget.border_bottom)
    @widget.border('dotted')
    assert_equal(@dotted, @widget.border_bottom)
  end

  def test_border_left
    assert_nil(@widget.border_left)
    @widget.border_left('blue_dash')
    assert_equal(@blue_dash, @widget.border_left)
    @widget.border('dotted')
    assert_equal(@dotted, @widget.border_left)
  end

  def test_margin
    assert_equal(0, @widget.margin_top)
    assert_equal(0, @widget.margin_right)
    assert_equal(0, @widget.margin_bottom)
    assert_equal(0, @widget.margin_left)

    @widget.margin('1in')
    assert_equal(1, @widget.margin_top(:in))
    assert_equal(1, @widget.margin_right(:in))
    assert_equal(1, @widget.margin_bottom(:in))
    assert_equal(1, @widget.margin_left(:in))

    assert_equal(72, @widget.margin_top)
    assert_equal(72, @widget.margin_right)
    assert_equal(72, @widget.margin_bottom)
    assert_equal(72, @widget.margin_left)

    @widget.margin('1cm,2cm')
    assert_equal(1, @widget.margin_top(:cm))
    assert_equal(2, @widget.margin_right(:cm))
    assert_equal(1, @widget.margin_bottom(:cm))
    assert_equal(2, @widget.margin_left(:cm))

    assert_equal(28.35, @widget.margin_top)
    assert_equal(56.7, @widget.margin_right)
    assert_equal(28.35, @widget.margin_bottom)
    assert_equal(56.7, @widget.margin_left)

    @widget.margin('1in,2cm,3cm,4pt')
    assert_equal(1, @widget.margin_top(:in))
    assert_equal(2, @widget.margin_right(:cm))
    assert_close(3, @widget.margin_bottom(:cm))
    assert_equal(4, @widget.margin_left(:pt))

    assert_equal(72, @widget.margin_top)
    assert_equal(56.7, @widget.margin_right)
    assert_close(85.05, @widget.margin_bottom)
    assert_equal(4, @widget.margin_left)
  end

  def test_margin_numeric
    @page.units(:in)
    @widget.margin(1)
    assert_equal([1,1,1,1], @widget.margin(:in))
    assert_equal([72,72,72,72], @widget.margin)
  end

  def test_padding
    assert_equal(0, @widget.padding_top)
    assert_equal(0, @widget.padding_right)
    assert_equal(0, @widget.padding_bottom)
    assert_equal(0, @widget.padding_left)

    @widget.padding('1in')
    assert_equal(1, @widget.padding_top(:in))
    assert_equal(1, @widget.padding_right(:in))
    assert_equal(1, @widget.padding_bottom(:in))
    assert_equal(1, @widget.padding_left(:in))

    assert_equal(72, @widget.padding_top)
    assert_equal(72, @widget.padding_right)
    assert_equal(72, @widget.padding_bottom)
    assert_equal(72, @widget.padding_left)

    @widget.padding('1cm,2cm')
    assert_equal(1, @widget.padding_top(:cm))
    assert_equal(2, @widget.padding_right(:cm))
    assert_equal(1, @widget.padding_bottom(:cm))
    assert_equal(2, @widget.padding_left(:cm))

    assert_equal(28.35, @widget.padding_top)
    assert_equal(56.7, @widget.padding_right)
    assert_equal(28.35, @widget.padding_bottom)
    assert_equal(56.7, @widget.padding_left)

    @widget.padding('1in,2cm,3cm,4pt')
    assert_equal(1, @widget.padding_top(:in))
    assert_equal(2, @widget.padding_right(:cm))
    assert_close(3, @widget.padding_bottom(:cm))
    assert_equal(4, @widget.padding_left(:pt))

    assert_equal(72, @widget.padding_top)
    assert_equal(56.7, @widget.padding_right)
    assert_close(85.05, @widget.padding_bottom)
    assert_equal(4, @widget.padding_left)
  end

  def test_padding_numeric
    @page.units(:in)
    @widget.padding(1)
    assert_equal([1,1,1,1], @widget.padding(:in))
    assert_equal([72,72,72,72], @widget.padding)
  end
end

class RectangleTestCases < Test::Unit::TestCase
  def setup
    page = Page.new(nil, :units => :pt)
    @rect = Rectangle.new(page)
    @rect1 = Rectangle.new(page, :corners => '1')
    @rect2 = Rectangle.new(page, :corners => '1,2')
    @rect3 = Rectangle.new(page, :corners => '1,2,3')
    @rect4 = Rectangle.new(page, :corners => '1,2,3,4')
    @rect8 = Rectangle.new(page, :corners => '1,2,3,4,5,6,7,8')
  end

  def test_corners
    assert_nil(@rect.corners)
    assert_equal([1], @rect1.corners)
    assert_equal([1,2], @rect2.corners)
    assert_nil(@rect3.corners) # ignores invalid number of corners
    assert_equal([1,2,3,4], @rect4.corners)
    assert_equal([1,2,3,4,5,6,7,8], @rect8.corners)
  end
end

class TextTestCases < Test::Unit::TestCase
  def setup
    @text = Text.new(nil)
  end

  def test_text
    assert_equal('', @text.text)
    @text.text("text")
    assert_equal("text", @text.text)
  end
end

class LabelTestCases < Test::Unit::TestCase
  def setup
    @label = StdWidgetFactory.instance.make_widget('label', nil)
  end

  def test_make_widget
    assert_not_nil(@label)
    assert(@label.is_a?(Label))
  end

  def test_angle
    assert_equal(0, @label.angle)
    @label.angle(90)
    assert_equal(90, @label.angle)
  end
end

class ParagraphTestCases < Test::Unit::TestCase
  Lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @centered = @doc.styles.add('para', :id => 'centered', :align => :center)
    @zapf = @doc.styles.add('font', :id => 'zapf', :name => 'ZapfDingbats', :size => 12)
    @bullet = @doc.styles.add('bullet', :id => 'bstar', :font => 'zapf', :text => "&#x4E;")
    @page = StdWidgetFactory.instance.make_widget('page', @doc)
    @p = StdWidgetFactory.instance.make_widget('p', @page)
    @writer = EideticPDF::DocumentWriter.new
    @writer.open
  end

  def teardown
    @writer.close
  end

  def test_make_widget
    assert_kind_of(Paragraph, @p)
    assert_equal(@page, @p.parent)
    assert_equal('p', @p.tag)
  end

  def test_bullet
    assert_nil(@p.bullet)
    @p.bullet('bstar')
    assert_equal(@bullet, @p.bullet)
    assert_equal(36, @p.bullet.width)
    assert_equal(0.5, @p.bullet.width(:in))
  end

  def assert_paragraph_defaults(ps)
    assert_equal(:left, ps.align)
    assert_nil(ps.bullet)
  end

  def test_style
    assert_paragraph_defaults(@doc.paragraph_style)
    assert_paragraph_defaults(@p.style)
    @p.style('centered')
    assert_equal(@centered, @p.style)
    assert_equal(:center, @p.text_align)
    assert_paragraph_defaults(@doc.paragraph_style)
  end

  def test_style_copy
    assert_paragraph_defaults(@doc.paragraph_style)
    assert_paragraph_defaults(@p.style)
    @p.style(:copy).align('right')
    assert_not_equal(@centered, @p.style)
    assert_equal(:right, @p.text_align)
    assert_paragraph_defaults(@doc.paragraph_style)
  end

  def test_preferred_width
    @page.margin("1in")
    @p.text(Lorem)
    pw = @p.preferred_width(@writer, :in)
    assert(pw <= 6.5)
    assert(pw >= 6.0)
  end

  def test_preferred_height_small
    @p.text("Hello")
    ph = @p.preferred_height(@writer)
    assert_in_delta(12, ph, 1)
  end

  def test_preferred_height_large
    @page.margin("1in")
    @p.text(Lorem)
    ph = @p.preferred_height(@writer)
    assert_in_delta(107, ph, 1)
  end
end

class ContainerTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @page = StdWidgetFactory.instance.make_widget('page', @doc)
    @centered = @doc.styles.add('para', :id => 'centered', :align => :center)
    @page.paragraph_style('centered')
    @div = StdWidgetFactory.instance.make_widget('div', @page)
  end

  def test_make_widget
    assert_equal(@page, @div.parent)
    assert_equal([0, 0, 0, 0], @div.margin)
  end

  def test_paragraph_style
    assert_equal(:center, @div.paragraph_style.align)
  end
end

class PageTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @doc.units('in')
    @legalland = @doc.styles.add('page', :id => 'legalland', :orientation => 'landscape', :size => 'legal')
    @page = StdWidgetFactory.instance.make_widget('page', @doc)
  end

  def test_make_widget
    assert_not_nil(@page)
    assert(@page.is_a?(Page))
    assert_equal(@doc, @page.parent)
  end

  def test_margin
    assert_equal([0,0,0,0], @doc.margin)
    assert_equal([0,0,0,0], @page.margin) # inherited

    @doc.margin('1')
    assert_equal([72,72,72,72], @doc.margin) # in points
    assert_equal(72, @doc.margin_top)
    assert_equal(72, @doc.margin_right)
    assert_equal(72, @doc.margin_bottom)
    assert_equal(72, @doc.margin_left)

    assert_equal([1,1,1,1], @doc.margin(:in)) # in specified units
    assert_equal(1, @doc.margin_top(:in))
    assert_equal(1, @doc.margin_right(:in))
    assert_equal(1, @doc.margin_bottom(:in))
    assert_equal(1, @doc.margin_left(:in))

    assert_equal([72,72,72,72], @page.margin) # inherited, in points
    assert_equal(72, @page.margin_top)
    assert_equal(72, @page.margin_right)
    assert_equal(72, @page.margin_bottom)
    assert_equal(72, @page.margin_left)

    assert_equal([1,1,1,1], @page.margin(:in)) # inherited, in specified units
    assert_equal(1, @page.margin_top(:in))
    assert_equal(1, @page.margin_right(:in))
    assert_equal(1, @page.margin_bottom(:in))
    assert_equal(1, @page.margin_left(:in))

    @page.margin('2')
    assert_equal([144,144,144,144], @page.margin) # in points
    assert_equal([2,2,2,2], @page.margin(:in)) # in specified units

    assert_equal([1,1,1,1], @doc.margin(:in)) # unchanged
    assert_equal([1,1,1,1], @doc.margin(:in)) # unchanged
  end

  def test_margin2
    doc = Document.new
    page = Page.new(doc, :margin => '1') # initialize margin in constructor
    assert_equal([1,1,1,1], page.margin)
  end

  def test_style
    assert_equal(:portrait, @page.style.orientation)
    assert_equal(:letter, @page.style.size)
    @page.style('legalland')
    assert_equal(:landscape, @page.style.orientation)
    assert_equal(:legal, @page.style.size)
  end

  def test_style_copy
    assert_equal(:portrait, @page.style.orientation)
    assert_equal(:letter, @page.style.size)
    default_style = @page.style
    @page.style(:copy).orientation('landscape')
    assert_not_equal(default_style, @page.style)
    assert_equal(:landscape, @page.style.orientation) # changed
    assert_equal(:letter, @page.style.size) # unchanged
  end

  def test_width
    assert_equal(8.5, @page.width(:in))
    @page.style('legalland')
    assert_equal(14, @page.width(:in))
  end

  def test_height
    assert_equal(11, @page.height(:in))
    @page.style('legalland')
    assert_equal(8.5, @page.height(:in))
  end
end

class DocumentTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @doc.units('in')
    @legalland = @doc.styles.add('page', :id => 'legalland', :orientation => 'landscape', :size => 'legal')
  end

  def test_make_widget
    assert_not_nil(@doc)
    assert(@doc.is_a?(Document))
  end

  def test_page_style
    assert_equal(:portrait, @doc.style.orientation)
    assert_equal(:letter, @doc.style.size)
    @doc.style('legalland')
    assert_equal(:landscape, @doc.style.orientation)
    assert_equal(:legal, @doc.style.size)
  end

  def test_width
    assert_equal(8.5, @doc.width(:in))
    @doc.style('legalland')
    assert_equal(14, @doc.width(:in))
  end

  def test_height
    assert_equal(11, @doc.height(:in))
    @doc.style('legalland')
    assert_equal(8.5, @doc.height(:in))
  end
end
