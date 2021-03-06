#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-02-22.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require "minitest/autorun"
require 'erml'
require 'erml_rules'

include EideticRML::Rules

class RuleTestCases < Minitest::Test
  def test_item_re_s
    assert_equal('foo(#\\w+)?(\\.\\w+)*',                 Rule.item_re_s('foo'))
    assert_equal('foo#bar(\\.\\w+)*',                     Rule.item_re_s('foo#bar'))
    assert_equal('foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*', Rule.item_re_s('foo.bar'))
    assert_equal('\w+#bar(\\.\\w+)*',                     Rule.item_re_s('#bar'))
    assert_equal('\w+(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*', Rule.item_re_s('.bar'))
  end

  def test_group_re_s
    assert_equal('foo#bar(\\.\\w+)*\\/foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*', Rule.group_re_s('foo#bar>foo.bar'))
  end

  def test_selector_re_s
    assert_equal('foo#bar(\\.\\w+)*\\/([^\\/]+\\/)*foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*$', Rule.selector_re_s('foo#bar foo.bar'))
    assert_equal('(foo(#\\w+)?(\\.\\w+)*$|bar(#\\w+)?(\\.\\w+)*$)', Rule.selector_re_s('foo, bar'))
  end

  def test_foo
    re = Regexp.compile Rule.selector_re_s('foo')
    assert re =~ 'foo'
    assert re =~ 'foo#bar'
    assert re =~ 'foo.bar'
    assert re =~ 'foo#bar.baz'
  end

  def test_foo_comma_bar
    re = Regexp.compile Rule.selector_re_s('foo, bar')
    assert re =~ 'foo'
    assert re =~ 'foo#bar'
    assert re =~ 'bar'
    assert re =~ 'bar.baz'
    assert re !~ 'baz'
  end

  def test_pound_bar
    re = Regexp.compile Rule.selector_re_s('#bar')
    assert re !~ 'foo'
    assert re =~ 'foo#bar'
    assert re !~ 'foo.bar'
    assert re =~ 'foo#bar.baz'
  end

  def test_dot_bar
    re = Regexp.compile Rule.selector_re_s('.bar')
    assert re !~ 'foo'
    assert re !~ 'foo#bar'
    assert re =~ 'foo.bar'
    assert re !~ 'foo#bar.baz'
  end

  def test_dot_baz
    re = Regexp.compile Rule.selector_re_s('.baz')
    assert re !~ 'foo'
    assert re !~ 'foo#bar'
    assert re !~ 'foo.bar'
    assert re =~ 'foo#bar.baz'
  end

  def test_direct_child
    re = Regexp.compile Rule.selector_re_s('foo#bar>foo.bar')
    assert re =~ 'foo#bar/foo.bar'
    assert re !~ 'foo.bar/foo#bar'
    assert re !~ 'foo#bar/foo#bar'
    assert re !~ 'foo.bar/foo.bar'
    assert re =~ 'foo#bar.baz/foo.bar'
    assert re =~ 'foo#bar/foo.bar.baz'
    assert re =~ 'foo#bar.baz/foo.bar.baz'
  end

  def test_indirect_child
    re = Regexp.compile Rule.selector_re_s('foo#bar foo.bar')
    assert re =~ 'foo#bar/foo.bar'
    assert re !~ 'foo.bar/foo#bar'
    assert re !~ 'foo#bar/foo#bar'
    assert re !~ 'foo.bar/foo.bar'
    assert re =~ 'foo#bar.baz/foo.bar'
    assert re =~ 'foo#bar/foo.bar.baz'
    assert re =~ 'foo#bar.baz/foo.bar.baz'

    assert re =~ 'foo#bar.baz/a/foo.bar.baz'
    assert re =~ 'foo#bar.baz/a#b/foo.bar.baz'
    assert re =~ 'foo#bar.baz/a.c/foo.bar.baz'
    assert re =~ 'foo#bar.baz/a#b.c/foo.bar.baz'
    assert re =~ 'foo#bar.baz/#b/foo.bar.baz'
    assert re =~ 'foo#bar.baz/.c/foo.bar.baz'
  end

  def test_parse
    rules_text = <<-END
  		table label { border: solid; padding: 2pt }
  		.reverse { font.style: Bold; font.color: Gray; }
      .rotated { rotate: 270; origin-y: bottom; }
      .trouble { rotate: 30; origin-x: center; origin-y: middle; fill: White }
    END
    expected = [
      ["table label", {"border"=>"solid", "padding"=>"2pt"}],
      [".reverse", {"font.style"=>"Bold", "font.color"=>"Gray"}],
      [".rotated", {"rotate"=>"270", "origin_y"=>"bottom"}],
      [".trouble", {"rotate"=>"30", "origin_x"=>"center", "origin_y"=>"middle", "fill"=>"White"}]
    ]
    assert_equal(expected, Rule.parse(rules_text))
  end
end
