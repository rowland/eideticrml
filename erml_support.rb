#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-07.
#  Copyright (c) 2008, Eidetic Software. All rights reserved.

module EideticRML
  module Support
    def parse_measurement(value, units=:pt)
      if value =~ /(\d+(\.\d+)?)(\w+)?/
        [$1.to_f, ($3 || 'pt').to_sym]
      else
        [value.to_f, units]
      end
    end

    module_function :parse_measurement
  end
end
