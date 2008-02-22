#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-02-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

module EideticRML
  module Klasses
    class Klass
      attr_reader :parent
      attr_reader :selector
      attr_reader :attrs

      def initialize(klasses, selector, attrs={}, parent=nil)
        @klasses, @parent = klasses, parent
        @selector = parent.nil? ? selector : parent.selector.dup << ' ' << selector
        @attrs = attrs.dup
      end

      def klass(tag, attrs={})
        @klasses << Klass.new(@klasses, Klass.selector_for(tag.to_s, attrs.delete('selector')), attrs, self)
        self
      end

      def root
        parent.nil? ? self : parent.root
      end

      def self.selector_for(tag, selector)
        tag = '' if tag =~ /^(_|[ck]lass)$/
        sel = tag.gsub(/^_(\w)/,'#\1')
        sel << ' ' if selector =~ /^\w/
        # sel << ' ' << selector unless selector.nil?
        sel << selector unless selector.nil?
        sel.gsub!(/\s{2,}/,' ') # collapse whitespace
        sel.gsub!(/\s*>\s*/,'>') # strip whitespace from right angle brackets
        sel
      end

      def update(attrs)
        @attrs.update(attrs)
        @selector_re = nil
      end

      def ===(path)
        selector_re =~ path
      end

      GT_RE = '\\/'
      SPACE_RE = GT_RE + '([^\\/]+\\/)*'
      TAG_RE = '\\w+'
      ID_RE = '(#\\w+)?'
      MISC_KLASS_RE = '(\\.\\w+)*'
      SPEC_KLASS_RE = '(\\.\\w+)*\\.%s(\\.\\w+)*'

      def selector_re
        @selector_re ||= Regexp.compile(Klass.selector_re_s(@selector))
      end

      def self.selector_re_s(selector)
        selector.split(' ').map { |group| group_re_s(group) }.join(SPACE_RE) << '$'
      end

      def self.group_re_s(group)
        group.split('>').map { |item| item_re_s(item) }.join(GT_RE)
      end

      def self.item_re_s(item)
        t, k = item.split('.', 2)
        if t == ''
          t = TAG_RE + ID_RE
        elsif t[0] == ?#
          t = TAG_RE + t
        elsif !t.include?('#')
          t << ID_RE
        end
        if k.nil? or k.empty?
          k = MISC_KLASS_RE
        else
          k = SPEC_KLASS_RE % k
        end
        t + k
      end
    end

    class KlassCollection < Array
      def add(tag, attrs={})
        selector = Klass.selector_for(tag.to_s, attrs.delete('selector'))
        klass = for_selector(selector)
        if klass.nil?
          klass = Klass.new(self, selector, attrs)
          self << klass
        else
          klass.update(attrs)
        end
        klass
      end

      def for_selector(selector)
        find { |klass| klass.selector == selector }
      end

      def matching(path)
        select { |klass| klass === path }
      end
    end
  end
end
