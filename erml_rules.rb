#!/usr/bin/env ruby
#
#  Created by Brent Rowland on 2008-02-06.
#  Copyright (c) 2008 Eidetic Software. All rights reserved.

module EideticRML
  module Rules
    class Rule
      attr_reader :parent
      attr_reader :selector
      attr_reader :attrs

      def initialize(rules, selector, attrs={}, parent=nil)
        @rules, @parent = rules, parent
        @selector = parent.nil? ? selector : parent.selector.dup << ' ' << selector
        @attrs = attrs.dup
      end

      def rule(tag, attrs={})
        @rules << Rule.new(@rules, Rule.selector_for(tag.to_s, attrs.delete('selector')), attrs, self)
        self
      end

      def root
        parent.nil? ? self : parent.root
      end

      def self.selector_for(tag, selector)
        tag = '' if tag =~ /^(_|rule)$/
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
      MISC_CLASS_RE = '(\\.\\w+)*'
      SPEC_CLASS_RE = '(\\.\\w+)*\\.%s(\\.\\w+)*'

      def selector_re
        @selector_re ||= Regexp.compile(Rule.selector_re_s(@selector))
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
          k = MISC_CLASS_RE
        else
          k = SPEC_CLASS_RE % k
        end
        t + k
      end

      def self.parse(text)
        text.scan(/\s*([^\{]+)\s*\{([^\}]+)\}/).map do |selector, rule|
          selector.strip!
          selector.gsub!(/\s{2,}/,' ') # collapse whitespace
          selector.gsub!(/\s*>\s*/,'>') # strip whitespace from right angle brackets
          attrs = rule.scan(/\s*([^:]+)\s*:\s*([^;]+)\s*;?/).inject({}) { |attrs, (k, v)| attrs[k] = v.strip; attrs }
          [selector, attrs]
        end
      end
    end

    class RuleCollection < Array
      def add(selector, attrs={})
        rule = for_selector(selector)
        if rule.nil?
          rule = Rule.new(self, selector, attrs)
          self << rule
        else
          rule.update(attrs)
        end
        rule
      end

      def for_selector(selector)
        find { |rule| rule.selector == selector }
      end

      def matching(path)
        select { |rule| rule === path }
      end
    end
  end
end
