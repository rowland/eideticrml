#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-07.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require 'test/unit'
require 'erml'
require 'erml_styles'
require 'erml_layout_managers'

include EideticRML::Styles
include EideticRML::LayoutManagers

class TestStyle < Style
end

class StyleTestCases < Test::Unit::TestCase
  def setup
    Style.register('test', TestStyle)
    @style = Style.new(nil)
  end

  def test_id
    assert_equal(nil, @style.id)
    @style.id 'foo'
    assert_equal('foo', @style.id)
    @style.id 33
    assert_equal('33', @style.id)
  end

  def test_register
    assert_equal(TestStyle, Style.class_eval("@@klasses['test']"))
  end

  def test_for_name
    assert_equal(TestStyle, Style.for_name('test'))
  end
end

class PenStyleTestCases < Test::Unit::TestCase
  def setup
    @pen_style = Style.for_name('pen').new(nil)
  end

  def test_initialize
    assert_not_nil(@pen_style)
    assert_kind_of(PenStyle, @pen_style)
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
    assert_equal(56.7, @pen_style.width)
    assert_equal(2, @pen_style.width(:cm))
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

  def test_cap
    assert_equal(:butt_cap, @pen_style.cap)
    @pen_style.cap 'round_cap'
    assert_equal(:round_cap, @pen_style.cap)
    @pen_style.cap 'projecting_square_cap'
    assert_equal(:projecting_square_cap, @pen_style.cap)
    @pen_style.cap 'butt_cap'
    assert_equal(:butt_cap, @pen_style.cap)
    @pen_style.cap 'bogus_cap_style'
    assert_equal(:butt_cap, @pen_style.cap) # unchanged
  end
end

class BrushStyleTestCases < Test::Unit::TestCase
  def setup
    @brush_style = Style.for_name('brush').new(nil)
  end

  def test_initialize
    assert_not_nil(@brush_style)
    assert_kind_of(BrushStyle, @brush_style)
  end

  def test_color
    assert_equal(0, @brush_style.color)
    @brush_style.color 'Blue'
    assert_equal('Blue', @brush_style.color)
    @brush_style.color 0xFF0000
    assert_equal(0xFF0000, @brush_style.color)
    @brush_style.color "#EEEEEE"
    assert_equal(0xEEEEEE, @brush_style.color)
    @brush_style.color "#999"
    assert_equal(0x090909, @brush_style.color)
  end
end

class FontStyleTestCases < Test::Unit::TestCase
  def setup
    @font_style = Style.for_name('font').new(nil)
  end

  def test_initialize
    assert_not_nil(@font_style)
    assert_kind_of(FontStyle, @font_style)
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

  def test_strikeout
    assert(!@font_style.strikeout)
    @font_style.strikeout(true)
    assert(@font_style.strikeout)
    @font_style.strikeout(false)
    assert(!@font_style.strikeout)
    @font_style.strikeout("true")
    assert(@font_style.strikeout)
    @font_style.strikeout("false")
    assert(!@font_style.strikeout)
  end

  def test_style
    assert_equal('', @font_style.style)
    @font_style.style 'Italic'
    assert_equal('Italic', @font_style.style)
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

  def test_underline
    assert(!@font_style.underline)
    @font_style.underline(true)
    assert(@font_style.underline)
    @font_style.underline(false)
    assert(!@font_style.underline)
    @font_style.underline("true")
    assert(@font_style.underline)
    @font_style.underline("false")
    assert(!@font_style.underline)
  end

  def test_weight
    assert_nil(@font_style.weight)
    @font_style.weight('Bold')
    assert_equal('Bold', @font_style.weight)
  end
end

class BulletStyleTestCases < Test::Unit::TestCase
  def setup
    @styles = StyleCollection.new
    @font_style = @styles.add('font', :id => 'f1', :name => 'Courier', :size => 13)
    @bullet_style = @styles.add('bullet', :id => 'b1')
  end

  def test_font
    assert_nil(@bullet_style.font)
    @bullet_style.font('f1')
    assert_equal(@font_style, @bullet_style.font)
  end

  def test_text
    assert_nil(@bullet_style.text)
    @bullet_style.text("*")
    assert_equal("*", @bullet_style.text)
  end

  def test_width1
    assert_equal(:pt, @bullet_style.units) # default units
    assert_equal(36, @bullet_style.width) # default width
    assert_equal(0.5, @bullet_style.width(:in)) # in specified units
  end

  def test_width2
    @bullet_style.width('18pt')
    assert_equal(18, @bullet_style.width)
    assert_equal(0.25, @bullet_style.width(:in))
  end

  def test_width3
    @bullet_style.units('cm')
    assert_equal(:cm, @bullet_style.units)
    @bullet_style.width('1')
    assert_equal(28.35, @bullet_style.width)
    assert_equal(1, @bullet_style.width(:cm))
  end
end

class ParagraphStyleTestCases < Test::Unit::TestCase
  def setup
    @styles = StyleCollection.new
    @bullet_style = @styles.add('bullet', :id => '*')
    @paragraph_style = @styles.add('para', :id => 'p')
  end

  def test_initialize
    assert_not_nil(@paragraph_style)
    assert_kind_of(ParagraphStyle, @paragraph_style)
  end

  def test_color
    assert_equal(0, @paragraph_style.color)
    @paragraph_style.color 'Red'
    assert_equal('Red', @paragraph_style.color)
  end

  def test_align
    assert_equal(:left, @paragraph_style.text_align)
    [:left, :center, :right, :justify].each do |align|
      @paragraph_style.text_align align
      assert_equal(align, @paragraph_style.text_align)
    end
    ['left', 'center', 'right', 'justify'].each do |align|
      @paragraph_style.text_align align
      assert_equal(align.to_sym, @paragraph_style.text_align)
    end
    @paragraph_style.text_align 'bogus'
    assert_equal(:justify, @paragraph_style.text_align) # last style successfully set
  end

  def test_bullet
    assert_nil(@paragraph_style.bullet)
    @paragraph_style.bullet '*'
    assert_equal(@bullet_style, @paragraph_style.bullet)
  end
end

class PageStyleTestCases < Test::Unit::TestCase
  def setup
    @page_style = Style.for_name('page').new(nil)
  end

  def test_initialize
    assert_not_nil(@page_style)
    assert_kind_of(PageStyle, @page_style)
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
    assert_equal(11, @page_style.height(:in))
  end

  def test_width
    assert_equal(612, @page_style.width)
    assert_equal(8.5, @page_style.width(:in))
  end
end

class LayoutStyleTestCases < Test::Unit::TestCase
  def setup
    @layout_style = Style.for_name('layout').new(nil)
  end

  def test_initialize
    assert_not_nil(@layout_style)
    assert_kind_of(LayoutStyle, @layout_style)
  end

  def test_padding
    assert_equal(0, @layout_style.padding)
    assert_equal(:pt, @layout_style.units)

    @layout_style.padding 5
    assert_equal(5, @layout_style.padding)

    @layout_style.padding 2, :cm
    assert_equal(56.7, @layout_style.padding)
    assert_equal(2, @layout_style.padding(:cm))

    @layout_style.padding 1, 'in'
    assert_equal(1, @layout_style.padding(:in))
    assert_equal(72, @layout_style.padding)

    @layout_style.padding '5pt'
    assert_equal(5, @layout_style.padding)

    @layout_style.padding '2cm'
    assert_equal(2, @layout_style.padding(:cm))
    assert_equal(56.7, @layout_style.padding)

    @layout_style.padding '1.25in'
    assert_equal(1.25, @layout_style.padding(:in))
  end

  def test_hpadding
    assert_equal(0, @layout_style.hpadding)

    @layout_style.hpadding 5
    assert_equal(5, @layout_style.hpadding)

    @layout_style.hpadding 2, :cm
    assert_equal(2, @layout_style.hpadding(:cm))

    @layout_style.hpadding 1, 'in'
    assert_equal(1, @layout_style.hpadding(:in))
    assert_equal(72, @layout_style.hpadding)

    @layout_style.hpadding '5pt'
    assert_equal(5, @layout_style.hpadding)

    @layout_style.hpadding '2cm'
    assert_equal(2, @layout_style.hpadding(:cm))
    assert_equal(56.7, @layout_style.hpadding)

    @layout_style.hpadding '1.25in'
    assert_equal(1.25, @layout_style.hpadding(:in))
  end

  def test_vpadding
    assert_equal(0, @layout_style.vpadding)

    @layout_style.vpadding 5
    assert_equal(5, @layout_style.vpadding)

    @layout_style.vpadding 2, :cm
    assert_equal(2, @layout_style.vpadding(:cm))

    @layout_style.vpadding 1, 'in'
    assert_equal(1, @layout_style.vpadding(:in))
    assert_equal(72, @layout_style.vpadding)

    @layout_style.vpadding '5pt'
    assert_equal(5, @layout_style.vpadding)

    @layout_style.vpadding '2cm'
    assert_equal(2, @layout_style.vpadding(:cm))
    assert_equal(56.7, @layout_style.vpadding)

    @layout_style.vpadding '1.25in'
    assert_equal(1.25, @layout_style.vpadding(:in))
  end

  def test_manager
    assert_nil(@layout_style.manager)
    @layout_style.manager('absolute')
    assert_kind_of(AbsoluteLayout, @layout_style.manager)
  end
end
