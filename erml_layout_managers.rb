#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

module EideticRML
  module LayoutManagers
    class LayoutManager
      def initialize(container, style)
        @container, @style = container, style
      end

      def layout(writer)
      end

      def self.register(name, klass)
        (@@klasses ||= {})[name] = klass
      end

      def self.for_name(name)
        @@klasses[name] unless @@klasses.nil?
      end
    end

    class AbsoluteLayout < LayoutManager
      register('absolute', self)

      def layout(writer)
        # TODO
      end
    end

    class FlowLayout < LayoutManager
      register('flow', self)

      def layout(writer)
        # TODO
      end
    end

    class HBoxLayout < LayoutManager
      register('hbox', self)

      def layout(writer)
        # TODO
      end
    end

    class VBoxLayout < LayoutManager
      register('vbox', self)

      def layout(writer)
        # TODO
      end
    end
    
    class TableLayout < LayoutManager
      register('table', self)
      
      def layout(writer)
        # TODO
      end
    end
  end
end
