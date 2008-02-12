#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-07.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

require 'rubygems'
require_gem 'eideticpdf'
require 'epdfpw'

module EideticRML
  module Support
    def parse_measurement(value, units=:pt)
      value, units = if value =~ /([+-]?\d+(\.\d+)?)([a-z]+)/
        [$1.to_f, ($3 || :pt).to_sym]
      else
        [value.to_f, units.to_sym]
      end
      units = :pt unless EideticPDF::UNIT_CONVERSION[units]
      [value, units]
    end

    def parse_measurement_pts(value, units=:pt)
      v, u = parse_measurement(value, units)
      v * EideticPDF::UNIT_CONVERSION[u]
    end

    def from_units(units, measurement)
      measurement.to_f * EideticPDF::UNIT_CONVERSION[units]
    end

    def to_units(units, measurement)
      measurement.to_f / EideticPDF::UNIT_CONVERSION[units]
    end

    module_function :parse_measurement, :parse_measurement_pts

    class Grid
      attr_reader :cols
      attr_accessor :rows

      def initialize(cols, rows)
        @cols, @rows = cols, rows
        @cells = Array.new(cols * rows)
      end

      def cols=(new_cols)
        @new_cells = Array.new(new_cols * rows)
        rows.times do |r|
          @new_cells[r * new_cols, cols] = @cells[r * cols, cols]
        end
        @cells = @new_cells
        @cols = new_cols
      end

      def rows=(value)
        if value > rows
          @cells.fill(nil, cols * rows, cols * (value - rows))
        elsif value < rows
          @cells.slice!(cols * value, cols * (rows - value))
        end
        @rows = value
      end

      def [](col, row)
        @cells[row * cols + col]
      end

      def []=(col, row, value)
        @rows = row + 1 if row >= @rows
        @cells[row * cols + col] = value
      end

      def col(index)
        result = []
        rows.times { |row| result << self[index, row] }
        result
      end

      def row(index)
        @cells.slice(index * cols, cols)
      end
    end
  end
end
