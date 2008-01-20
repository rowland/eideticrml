#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-07.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require 'test/unit'
require 'erml'
require 'erml_styles'

include EideticRML::Styles

class StyleTestCases < Test::Unit::TestCase
  def setup
    @style = Style.new
  end

  def test_id
    assert_equal(nil, @style.id)
    @style.id 'foo'
    assert_equal('foo', @style.id)
    @style.id 33
    assert_equal('33', @style.id)
  end
end

class PenStyleTestCases < Test::Unit::TestCase
  def setup
    @pen_style = PenStyle.new
  end

  def test_units
    assert_equal(:pt, @pen_style.units)
  end

  def test_width
    assert_equal(0, @pen_style.width)
    @pen_style.width 123
    assert_equal(123, @pen_style.width)
    assert_equal(:pt, @pen_style.units)
    @pen_style.width 456.789
    assert_equal(456.789, @pen_style.width)
    assert_equal(:pt, @pen_style.units)
    @pen_style.width '123'
    assert_equal(123, @pen_style.width)
    assert_equal(:pt, @pen_style.units)
    @pen_style.width '2cm'
    assert_equal(2, @pen_style.width)
    assert_equal(:cm, @pen_style.units)
  end

  def test_pattern
    assert_equal(:solid, @pen_style.pattern)
    @pen_style.pattern :dotted
    assert_equal(:dotted, @pen_style.pattern)
    @pen_style.pattern 'dashed'
    assert_equal(:dashed, @pen_style.pattern)
    @pen_style.pattern '[1, 10]'
    assert_equal('[1, 10]', @pen_style.pattern)
  end

  def test_color
    assert_equal(0, @pen_style.color)
    @pen_style.color 'Blue'
    assert_equal('Blue', @pen_style.color)
    @pen_style.color 0xFF0000
    assert_equal(0xFF0000, @pen_style.color)
  end
end

class BrushStyleTestCases < Test::Unit::TestCase
  def setup
    @brush_style = BrushStyle.new
  end

  def test_color
    assert_equal(0, @brush_style.color)
    @brush_style.color 'Blue'
    assert_equal('Blue', @brush_style.color)
    @brush_style.color 0xFF0000
    assert_equal(0xFF0000, @brush_style.color)
  end
end

class FontStyleTestCases < Test::Unit::TestCase
  def setup
    @font_style = FontStyle.new
  end

  def test_color
    assert_equal(0, @font_style.color)
    @font_style.color 'Red'
    assert_equal('Red', @font_style.color)
  end
  
  def test_name
    assert_equal('Helvetica', @font_style.name)
    @font_style.name 'bigred'
    assert_equal('bigred', @font_style.name)
  end
  
  def test_size
    assert_equal(12, @font_style.size)
    @font_style.size 14.5
    assert_equal(14.5, @font_style.size)
  end
  
  def test_style
    assert_equal('', @font_style.style)
    @font_style.style 'Bold'
    assert_equal('Bold', @font_style.style)
  end
  
  def test_encoding
    assert_equal('WinAnsiEncoding', @font_style.encoding)
    @font_style.encoding 'StandardEncoding'
    assert_equal('StandardEncoding', @font_style.encoding)
  end
  
  def test_sub_type
    assert_equal('Type1', @font_style.sub_type)
    @font_style.sub_type 'TrueType'
    assert_equal('TrueType', @font_style.sub_type)
  end
end

class ParagraphStyleTestCases < Test::Unit::TestCase
  def setup
    @paragraph_style = ParagraphStyle.new
  end

  def test_color
    assert_equal(0, @paragraph_style.color)
    @paragraph_style.color 'Red'
    assert_equal('Red', @paragraph_style.color)
  end

  def test_align
    assert_equal(:left, @paragraph_style.align)
    [:left, :center, :right, :justify].each do |align|
      @paragraph_style.align align
      assert_equal(align, @paragraph_style.align)
    end
    ['left', 'center', 'right', 'justify'].each do |align|
      @paragraph_style.align align
      assert_equal(align.to_sym, @paragraph_style.align)
    end
    @paragraph_style.align 'bogus'
    assert_equal(:justify, @paragraph_style.align) # last style successfully set
  end

  def test_bullet
    assert_nil(@paragraph_style.bullet)
    @paragraph_style.bullet '*'
    assert_equal('*', @paragraph_style.bullet)
  end
end

class PageStyleTestCases < Test::Unit::TestCase
  def setup
    @page_style = PageStyle.new
  end

  def test_size
    assert_equal(:letter, @page_style.size)
    @page_style.size 'bogus'
    assert_equal(:letter, @page_style.size) # unchanged
    @page_style.size :legal
    assert_equal(:legal, @page_style.size)
    ['A4', 'B5', 'C5'].each do |size|
      @page_style.size size
      assert_equal(size.to_sym, @page_style.size)
    end
  end

  def test_orientation
    assert_equal(:portrait, @page_style.orientation)
    @page_style.orientation :landscape
    assert_equal(:landscape, @page_style.orientation)
    ['portrait', 'landscape'].each do |orientation|
      @page_style.orientation orientation
      assert_equal(orientation.to_sym, @page_style.orientation)
    end
    @page_style.orientation 'bogus'
    assert_equal(:landscape, @page_style.orientation)
  end

  def test_height
    assert_equal(792, @page_style.height)
  end

  def test_width
    assert_equal(612, @page_style.width)
  end
end

class LayoutStyleTestCases < Test::Unit::TestCase
  def setup
    @layout_style = LayoutStyle.new
  end

  def test_padding
    assert_equal(0, @layout_style.padding)

    @layout_style.padding 5
    assert_equal([5, :pt], [@layout_style.padding, @layout_style.units])
    @layout_style.padding 2, :cm
    assert_equal([2, :cm], [@layout_style.padding, @layout_style.units])
    @layout_style.padding 1, 'in'
    assert_equal([1, :in], [@layout_style.padding, @layout_style.units])

    @layout_style.padding '5pt'
    assert_equal([5, :pt], [@layout_style.padding, @layout_style.units])
    @layout_style.padding '2cm'
    assert_equal([2, :cm], [@layout_style.padding, @layout_style.units])
    @layout_style.padding '1.25in'
    assert_equal([1.25, :in], [@layout_style.padding, @layout_style.units])
  end

  def test_hpadding
    assert_equal(0, @layout_style.hpadding)

    @layout_style.hpadding 5
    assert_equal([5, :pt], [@layout_style.hpadding, @layout_style.units])
    @layout_style.hpadding 2, :cm
    assert_equal([2, :cm], [@layout_style.hpadding, @layout_style.units])
    @layout_style.hpadding 1, 'in'
    assert_equal([1, :in], [@layout_style.hpadding, @layout_style.units])

    @layout_style.hpadding '5pt'
    assert_equal([5, :pt], [@layout_style.hpadding, @layout_style.units])
    @layout_style.hpadding '2cm'
    assert_equal([2, :cm], [@layout_style.hpadding, @layout_style.units])
    @layout_style.hpadding '1.25in'
    assert_equal([1.25, :in], [@layout_style.hpadding, @layout_style.units])
  end

  def test_vpadding
    assert_equal(0, @layout_style.vpadding)

    @layout_style.vpadding 5
    assert_equal([5, :pt], [@layout_style.vpadding, @layout_style.units])
    @layout_style.vpadding 2, :cm
    assert_equal([2, :cm], [@layout_style.vpadding, @layout_style.units])
    @layout_style.vpadding 1, 'in'
    assert_equal([1, :in], [@layout_style.vpadding, @layout_style.units])

    @layout_style.vpadding '5pt'
    assert_equal([5, :pt], [@layout_style.vpadding, @layout_style.units])
    @layout_style.vpadding '2cm'
    assert_equal([2, :cm], [@layout_style.vpadding, @layout_style.units])
    @layout_style.vpadding '1.25in'
    assert_equal([1.25, :in], [@layout_style.vpadding, @layout_style.units])
  end

  def test_manager # TODO
  end
end
