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
  end
end
