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
      value, units = if value =~ /(\d+(\.\d+)?)(\w+)?/
        [$1.to_f, ($3 || :pt).to_sym]
      else
        [value.to_f, units.to_sym]
      end
      units = :pt unless EideticPDF::UNIT_CONVERSION[units]
      [value, units]
    end

    def from_units(units, measurement)
      units == self.units ?
        measurement :
        measurement.to_f * EideticPDF::UNIT_CONVERSION[units] / EideticPDF::UNIT_CONVERSION[self.units]
    end

    def to_units(units, measurement)
      units == self.units ?
        measurement :
        measurement.to_f * EideticPDF::UNIT_CONVERSION[self.units] / EideticPDF::UNIT_CONVERSION[units]
    end

    module_function :parse_measurement
  end
end
