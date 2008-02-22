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

      def register_widget(tag, klass)
        @klasses[tag] = klass
      end

      def has_widget?(tag)
        !!@klasses[tag]
      end

      def make_widget(tag, parent, attrs={})
        attrs['tag'] = tag unless attrs['tag']
        attrs['class'] = '' if attrs['class'].nil?
        @klasses[tag].new(parent, attrs)
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
