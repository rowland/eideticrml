#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-07.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require 'test/unit'
require 'erml_support'

include EideticRML

class ErmlSupportTestCases < Test::Unit::TestCase
  def test_parse_measurement
    assert_equal([123, :pt], Support::parse_measurement("123"))
    assert_equal([123.456, :pt], Support::parse_measurement("123.456"))
    assert_equal([123, :cm], Support::parse_measurement("123cm"))
    assert_equal([123.456, :cm], Support::parse_measurement("123.456cm"))
  end
end
