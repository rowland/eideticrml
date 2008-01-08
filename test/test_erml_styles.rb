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
    assert_equal(:pt, @pen_style.units)
    assert_equal(123, @pen_style.width)
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
end
