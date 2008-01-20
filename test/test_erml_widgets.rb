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
    @doc.styles << @alt
    @widget = Widget.new(@doc)
  end

  def test_initialize
    assert_not_nil(@widget)
    assert_equal(@doc, @widget.parent)
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
    @div = StdWidgetFactory.instance.make_widget('page', @page)
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

  def test_paragraph_style
    assert_equal(:center, @div.paragraph_style.align)
  end
end

class PageTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
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
end

class DocumentTestCases < Test::Unit::TestCase
  def setup
    @doc = StdWidgetFactory.instance.make_widget('erml', nil)
  end

  def test_make_widget
    assert_not_nil(@doc)
    assert(@doc.is_a?(Document))
  end
end