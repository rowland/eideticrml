#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-16.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require "minitest/autorun"
require 'erml_widgets'
require 'erml_widget_factories'

include EideticRML::Widgets

class TestWidget < Widget
end

class FactoryTestCases < Minitest::Test
  def setup
    @wf = WidgetFactory.new
    WidgetFactory.register_factory('test', @wf)
  end

  def test_register_factory
    assert_equal(@wf, WidgetFactory.class_eval("@@factories['test']"))
  end

  def test_for_namespace
    assert_equal(@wf, WidgetFactory.for_namespace('test'))
  end

  def test_register_widget
    @wf.register_widget('test_widget', TestWidget)
    assert_equal(TestWidget, @wf.instance_eval("@klasses['test_widget']"))
  end

  def test_has_widget?
    @wf.register_widget('test_widget', TestWidget)
    assert(@wf.has_widget?('test_widget'))
  end

  def test_make_widget
    @wf.register_widget('test_widget', TestWidget)
    w = @wf.make_widget('test_widget', nil)
    refute_nil(w)
    assert(w.is_a?(TestWidget))
  end
end
