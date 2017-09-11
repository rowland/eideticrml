#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-07.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

$: << File.dirname(__FILE__) + '/../'
require "minitest/autorun"
require 'erml_support'

include EideticRML

class ErmlSupportTestCases < Minitest::Test
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

class GridTestCases < Minitest::Test
  def setup
    @grid = Support::Grid.new(3, 2)
  end

  def test_index_get
    3.times do |c|
      2.times do |r|
        assert_equal(nil, @grid[c,r])
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

  def get3
    assert_equal(1,  @grid[0, 0])
    assert_equal(2,  @grid[1, 0])
    assert_equal(3,  @grid[2, 0])
  end

  def get4
    assert_equal(1,  @grid[0, 0])
    assert_equal(2,  @grid[1, 0])
    assert_equal(4,  @grid[0, 1])
    assert_equal(5,  @grid[1, 1])
  end

  def get6
    get3
    assert_equal(4,  @grid[0, 1])
    assert_equal(5,  @grid[1, 1])
    assert_equal(6,  @grid[2, 1])
  end

  def test_index_set
    set6
    get6
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

  def test_resize_rows_larger
    set6
    @grid.rows = 4
    assert_equal(4, @grid.rows)
    get6
  end

  def test_resize_rows_smaller
    set6
    @grid.rows = 1
    assert_equal(1, @grid.rows)
    get3
  end

  def test_resize_cols_larger
    set6
    @grid.cols = 5
    assert_equal(5, @grid.cols)
    get6
  end

  def test_resize_cols_smaller
    set6
    @grid.cols = 2
    get4
  end
end

class BoundsTestCases < Minitest::Test
  def test_init_empty
    b = Support::Bounds.new
    assert_equal nil, b.left
    assert_equal nil, b.top
    assert_equal nil, b.right
    assert_equal nil, b.bottom
  end

  def test_init_full
    b = Support::Bounds.new(3,5,7,11)
    assert_equal 3, b.left
    assert_equal 5, b.top
    assert_equal 7, b.right
    assert_equal 11, b.bottom
  end

  def test_width_height
    b = Support::Bounds.new(3,5,7,11)
    assert_equal 4, b.width
    assert_equal 6, b.height
  end
end
