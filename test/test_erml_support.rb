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
    assert_equal([2, :in], Support::parse_measurement("2", :in))
  end

  def test_parse_measurement_pts
    assert_equal(123, Support::parse_measurement_pts("123"))
    assert_equal(123.456, Support::parse_measurement_pts("123.456"))
    assert_equal(3487.05, Support::parse_measurement_pts("123cm"))
    assert_equal(3499.9776, Support::parse_measurement_pts("123.456cm"))
    assert_equal(144, Support::parse_measurement_pts("2", :in))
  end
end

class GridTestCases < Test::Unit::TestCase
  def setup
    @grid = Support::Grid.new(3, 2, 0)
  end

  def test_index_get
    3.times do |c|
      2.times do |r|
        assert_equal(0, @grid[c,r])
      end
    end
  end

  def set6
    @grid[0, 0] = 1
    @grid[1, 0] = 2
    @grid[2, 0] = 3
    @grid[0, 1] = 4
    @grid[1, 1] = 5
    @grid[2, 1] = 6
  end

  def test_index_set
    set6
    assert_equal(1,  @grid[0, 0])
    assert_equal(2,  @grid[1, 0])
    assert_equal(3,  @grid[2, 0])
    assert_equal(4,  @grid[0, 1])
    assert_equal(5,  @grid[1, 1])
    assert_equal(6,  @grid[2, 1])
  end
  
  def test_col
    set6
    assert_equal([1, 4], @grid.col(0))
    assert_equal([2, 5], @grid.col(1))
    assert_equal([3, 6], @grid.col(2))
  end

  def test_row
    set6
    assert_equal([1, 2, 3], @grid.row(0))
    assert_equal([4, 5, 6], @grid.row(1))
  end
end
