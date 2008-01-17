#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-01-16.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

module EideticRML
  module Widgets
    class WidgetFactory
      def initialize
        @klasses = {}
      end

      def register_widget(name, klass)
        @klasses[name] = klass
      end

      def make_widget(name, parent)
        @klasses[name].new(parent)
      end

      @@factories = {}

      def self.for_namespace(namespace)
        @@factories[namespace]
      end

      def self.register_factory(namespace, factory)
        @@factories[namespace] = factory
      end
    end
  end
end
