#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-16.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require 'test/unit'
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
    @alt = FontStyle.new(:id => 'alt', :name => 'Times', :size => 10, :style => 'Bold', :encoding => 'CP1252', :color => '0xFFFFFF')
    @blue_dash = PenStyle.new(:id => 'blue_dash', :color => 'Blue', :width => '4pt', :pattern => 'dashed')
    @doc.styles << @alt << @blue_dash
    @page = StdWidgetFactory.instance.make_widget('page', @doc)
    @widget = Widget.new(@page)
  end

  def test_initialize
    assert_not_nil(@widget)
    assert_equal(@page, @widget.parent)
  end

  def test_units
    assert_equal(:pt, @doc.units)
    assert_equal(:pt, @widget.units)
    @widget.units(:in)
    assert_equal(:in, @widget.units)
    assert_equal(:pt, @doc.units)
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

  def test_font_style
    @widget.font_style('Bold')
    assert_equal('Bold', @widget.font.style)
    assert_font_defaults(@doc.font) # unchanged
  end

  def test_width
    @page.units(:in)
    assert_equal(0, @widget.width)
    @widget.width('5')
    assert_equal(5, @widget.width)
    @widget.width('50%')
    assert_equal(0.5, @widget.width_pct)
    assert_equal(4.25, @widget.width)
  end

  def test_height
    @page.units(:in)
    assert_equal(0, @widget.height)
    @widget.height('3.5')
    assert_equal(3.5, @widget.height)
    @widget.height('50%')
    assert_equal(0.5, @widget.height_pct)
    assert_equal(5.5, @widget.height)
  end

  def test_content_width
    assert_equal(0, @widget.content_width)
    @widget.width('5')
    assert_equal(5, @widget.content_width) # same as width unless overridden
  end

  def test_content_height
    assert_equal(0, @widget.content_height)
    @widget.height('3.5')
    assert_equal(3.5, @widget.content_height) # same as height unless overridden
  end

  def test_borders
    assert_nil(@widget.borders)
    @widget.borders('blue_dash')
    assert_not_nil(@widget.borders)
    assert_equal('blue_dash', @widget.borders.id)
    assert_equal('Blue', @widget.borders.color)
    assert_equal(4, @widget.borders.width)
    assert_equal(:pt, @widget.borders.units)
  end
end

class RectangleTestCases < Test::Unit::TestCase
  def setup
    @rect = Rectangle.new(nil)
    @rect1 = Rectangle.new(nil, :corners => '1')
    @rect2 = Rectangle.new(nil, :corners => '1,2')
    @rect3 = Rectangle.new(nil, :corners => '1,2,3')
    @rect4 = Rectangle.new(nil, :corners => '1,2,3,4')
    @rect8 = Rectangle.new(nil, :corners => '1,2,3,4,5,6,7,8')
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

class ParagraphTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @centered = ParagraphStyle.new(:id => 'centered', :align => :center)
    @doc.styles << @centered
    @p = StdWidgetFactory.instance.make_widget('p', @doc)
  end

  def test_make_widget
    assert_kind_of(Paragraph, @p)
    assert_equal(@doc, @p.parent)
  end

  def test_text
    assert_equal('', @p.text)
    @p.text("paragraph")
    assert_equal("paragraph", @p.text)
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
    assert_equal(:center, @p.align)
    assert_paragraph_defaults(@doc.paragraph_style)
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

  def test_text
    assert_equal('', @label.text)
    @label.text("label")
    assert_equal("label", @label.text)
  end
end

class ContainerTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @page = StdWidgetFactory.instance.make_widget('page', @doc)
    @centered = ParagraphStyle.new(:id => 'centered', :align => :center)
    @doc.styles << @centered
    @page.paragraph_style('centered')
    @div = StdWidgetFactory.instance.make_widget('div', @page)
  end

  def test_make_widget
    assert_equal(@page, @div.parent)
    assert_equal([0, 0, 0, 0], @div.margins)
  end

  def test_margins
    assert_equal(0, @div.margin_top)
    assert_equal(0, @div.margin_right)
    assert_equal(0, @div.margin_bottom)
    assert_equal(0, @div.margin_left)
    @div.margins('1')
    assert_equal(1, @div.margin_top)
    assert_equal(1, @div.margin_right)
    assert_equal(1, @div.margin_bottom)
    assert_equal(1, @div.margin_left)
    @div.margins('1,2')
    assert_equal(1, @div.margin_top)
    assert_equal(2, @div.margin_right)
    assert_equal(1, @div.margin_bottom)
    assert_equal(2, @div.margin_left)
    @div.margins('1,2,3,4')
    assert_equal(1, @div.margin_top)
    assert_equal(2, @div.margin_right)
    assert_equal(3, @div.margin_bottom)
    assert_equal(4, @div.margin_left)
  end

  def test_margins2
    doc = Document.new
    page = Page.new(doc, :margins => '1') # initialize margins in constructor
    assert_equal([1,1,1,1], page.margins)
  end

  def test_paragraph_style
    assert_equal(:center, @div.paragraph_style.align)
  end

  def test_content_width
    @div.width(10)
    assert_equal(10, @div.content_width)
    @div.margins([1,2,3,4])
    assert_equal(4, @div.content_width)
  end

  def test_content_height
    @div.height(10)
    assert_equal(10, @div.content_height)
    @div.margins([1,2,3,4])
    assert_equal(6, @div.content_height)
  end
end

class PageTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @doc.units('in')
    @legalland = PageStyle.new(:id => 'legalland', :orientation => 'landscape', :size => 'legal')
    @doc.styles << @legalland
    @page = StdWidgetFactory.instance.make_widget('page', @doc)
  end

  def test_make_widget
    assert_not_nil(@page)
    assert(@page.is_a?(Page))
    assert_equal(@doc, @page.parent)
  end

  def test_margins
    assert_equal([0,0,0,0], @doc.margins)
    assert_equal([0,0,0,0], @page.margins)
    @doc.margins('1')
    assert_equal([1,1,1,1], @doc.margins)
    assert_equal([1,1,1,1], @page.margins)
    @page.margins('2')
    assert_equal([2,2,2,2], @page.margins)
    assert_equal([1,1,1,1], @doc.margins) # unchanged
  end

  def test_style
    assert_equal(:portrait, @page.style.orientation)
    assert_equal(:letter, @page.style.size)
    @page.style('legalland')
    assert_equal(:landscape, @page.style.orientation)
    assert_equal(:legal, @page.style.size)
  end

  def test_width
    assert_equal(8.5, @page.width)
    @page.style('legalland')
    assert_equal(14, @page.width)
  end

  def test_height
    assert_equal(11, @page.height)
    @page.style('legalland')
    assert_equal(8.5, @page.height)
  end
end

class DocumentTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
    @doc.units('in')
    @legalland = PageStyle.new(:id => 'legalland', :orientation => 'landscape', :size => 'legal')
    @doc.styles << @legalland
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
    assert_equal(8.5, @doc.width)
    @doc.style('legalland')
    assert_equal(14, @doc.width)
  end

  def test_height
    assert_equal(11, @doc.height)
    @doc.style('legalland')
    assert_equal(8.5, @doc.height)
  end
end
