#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-21.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require 'test/unit'
require 'erml_layout_managers'
require 'erml_widgets'
require 'erml_styles'

include EideticRML::LayoutManagers
include EideticRML::Widgets
include EideticRML::Styles

class TestLayout < LayoutManager
end

class LayoutManagerTestCases < Test::Unit::TestCase
  def setup
    LayoutManager.register('test', TestLayout)
  end

  def test_register
    assert_equal(TestLayout, LayoutManager.class_eval("@@klasses['test']"))
  end

  def test_for_name
    assert_equal(TestLayout, LayoutManager.for_name('test'))
  end
end

class AbsoluteLayoutTestCases < Test::Unit::TestCase
  def setup
    @container = Container.new(nil)
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('absolute').new(@container, @style)
  end

  def test_initialize
    assert_not_nil(@lm)
    assert_kind_of(AbsoluteLayout, @lm)
  end

  def test_layout(writer)
  end
end

class FlowLayoutTestCases < Test::Unit::TestCase
  def setup
    @container = Container.new(nil)
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('flow').new(@container, @style)
  end

  def test_initialize
    assert_not_nil(@lm)
    assert_kind_of(FlowLayout, @lm)
  end

  def test_layout(writer)
  end
end

class HBoxLayoutTestCases < Test::Unit::TestCase
  def setup
    @container = Container.new(nil)
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('hbox').new(@container, @style)
  end

  def test_initialize
    assert_not_nil(@lm)
    assert_kind_of(HBoxLayout, @lm)
  end

  def test_layout(writer)
  end
end

class VBoxLayoutTestCases < Test::Unit::TestCase
  def setup
    @container = Container.new(nil)
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('vbox').new(@container, @style)
  end

  def test_initialize
    assert_not_nil(@lm)
    assert_kind_of(VBoxLayout, @lm)
  end

  def test_layout(writer)
  end
end

class TableLayoutTestCases < Test::Unit::TestCase
  def setup
    @container = Container.new(nil)
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('table').new(@container, @style)
  end

  def test_initialize
    assert_not_nil(@lm)
    assert_kind_of(TableLayout, @lm)
  end

  def test_layout(writer)
  end
end
