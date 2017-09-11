#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-21.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require "minitest/autorun"
require 'erml_layout_managers'
require 'erml_widgets'
require 'erml_styles'

include EideticRML::LayoutManagers
include EideticRML::Widgets
include EideticRML::Styles

class TestLayout < LayoutManager
end

class LayoutManagerTestCases < Minitest::Test
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

class AbsoluteLayoutTestCases < Minitest::Test
  def setup
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('absolute').new(@style)
  end

  def test_initialize
    refute_nil(@lm)
    assert_kind_of(AbsoluteLayout, @lm)
  end

  # def test_layout(writer)
  # end
end

class FlowLayoutTestCases < Minitest::Test
  def setup
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('flow').new(@style)
  end

  def test_initialize
    refute_nil(@lm)
    assert_kind_of(FlowLayout, @lm)
  end

  # def test_layout(writer)
  # end
end

class HBoxLayoutTestCases < Minitest::Test
  def setup
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('hbox').new(@style)
  end

  def test_initialize
    refute_nil(@lm)
    assert_kind_of(HBoxLayout, @lm)
  end

  # def test_layout(writer)
  # end
end

class VBoxLayoutTestCases < Minitest::Test
  def setup
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('vbox').new(@style)
  end

  def test_initialize
    refute_nil(@lm)
    assert_kind_of(VBoxLayout, @lm)
  end

  # def test_layout(writer)
  # end
end

class TableLayoutTestCases < Minitest::Test
  def setup
    @style = LayoutStyle.new(nil)
    @lm = LayoutManager.for_name('table').new(@style)
  end

  def test_initialize
    refute_nil(@lm)
    assert_kind_of(TableLayout, @lm)
  end

  # def test_layout(writer)
  # end
end
