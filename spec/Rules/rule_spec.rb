require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Rules
    describe Rule do
      context "item_re_s regex's" do
        it "should generate an expression matching a tag" do
          assert_equal('foo(#\\w+)?(\\.\\w+)*',                 Rule.item_re_s('foo'))
        end

        it "should generate an expression matching a tag with an id" do
          assert_equal('foo#bar(\\.\\w+)*',                     Rule.item_re_s('foo#bar'))
        end

        it "should generate an expression matching a tag with a class" do
          assert_equal('foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*', Rule.item_re_s('foo.bar'))
        end

        it "should generate an expression matching an id" do
          assert_equal('\w+#bar(\\.\\w+)*',                     Rule.item_re_s('#bar'))
        end

        it "should generate an expression matching a class" do
          assert_equal('\w+(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*', Rule.item_re_s('.bar'))
        end
      end

      context "group_re_s regex's" do
        it "should generate an expression matching a tag with a class that is the direct child of a tag with an id" do
          assert_equal('foo#bar(\\.\\w+)*\\/foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*', Rule.group_re_s('foo#bar>foo.bar'))
        end
      end

      context "selector_re_s regex's" do
        it "should generate an expression matching a tag with a class that is a descendent of a tag with an id" do
          assert_equal('foo#bar(\\.\\w+)*\\/([^\\/]+\\/)*foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*$', Rule.selector_re_s('foo#bar foo.bar'))
        end

        it "should generate an expression matching any of a comma-delimited list of tags" do
          assert_equal('(foo(#\\w+)?(\\.\\w+)*$|bar(#\\w+)?(\\.\\w+)*$)', Rule.selector_re_s('foo, bar'))
        end
      end

      context "selector_re_s matching a tag" do
        before :each do
          re = Regexp.compile Rule.selector_re_s('foo')
        end

        it "should match a tag" do
          assert re =~ 'foo'
        end

        it "should match a tag with an id" do
          assert re =~ 'foo#bar'
        end

        it "should match a tag with a class" do
          assert re =~ 'foo.bar'
        end

        it "should match a tag with an id and a class" do
          assert re =~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching either of two tags" do
        before :each do
          re = Regexp.compile Rule.selector_re_s('foo, bar')
        end

        it "should match the first tag" do
          assert re =~ 'foo'
        end

        it "should match the first tag with an id" do
          assert re =~ 'foo#bar'
        end

        it "should match the second tag" do
          assert re =~ 'bar'
        end

        it "shold match the second tag with a class" do
          assert re =~ 'bar.baz'
        end

        it "should not match an unspecified tag" do
          assert re !~ 'baz'
        end
      end

      context "selector_re_s matching an id" do
        before :each do
          re = Regexp.compile Rule.selector_re_s('#bar')
        end

        it "should not match just a simple tag" do
          assert re !~ 'foo'
        end

        it "should match a tag with the specified id" do
          assert re =~ 'foo#bar'
        end

        it "should not match a tag with an id but no class" do
          assert re !~ 'foo.bar'
        end

        it "should match a tag with the specified id and a class" do
          assert re =~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching a class" do
        before :each do
          re = Regexp.compile Rule.selector_re_s('.bar')
        end

        it "should not match just a simple tag" do
          assert re !~ 'foo'
        end

        it "should not match a tag with an id but no class" do
          assert re !~ 'foo#bar'
        end

        it "should match a tag with the specified class" do
          assert re =~ 'foo.bar'
        end

        it "should not match a tag with an id named the same as the specified class" do
          assert re !~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching another class" do
        before :each do
          re = Regexp.compile Rule.selector_re_s('.baz')
        end

        it "should not match just a simple tag" do
          assert re !~ 'foo'
        end

        it "should not match a tag with an id but no class" do
          assert re !~ 'foo#bar'
        end

        it "should not match a tag with the wrong class" do
          assert re !~ 'foo.bar'
        end

        it "should match a tag with an id and the specified class" do
          assert re =~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching a direct child" do
        before :each do
          re = Regexp.compile Rule.selector_re_s('foo#bar>foo.bar')
        end

        it "should match an element exactly as specified" do
          assert re =~ 'foo#bar/foo.bar'
        end

        it "should not match an element where the id and the class have been switched" do
          assert re !~ 'foo.bar/foo#bar'
        end

        it "should not match an element where an id has been traded for a class" do
          assert re !~ 'foo#bar/foo#bar'
        end

        it "should not match an element where a class has been traded for an id" do
          assert re !~ 'foo.bar/foo.bar'
        end

        it "should match an element as specified with a class added to the parent" do
          assert re =~ 'foo#bar.baz/foo.bar'
        end

        it "should match an element as specified with a class added to the child" do
          assert re =~ 'foo#bar/foo.bar.baz'
        end

        it "should match an element as specified with classes added to both parent and child" do
          assert re =~ 'foo#bar.baz/foo.bar.baz'
        end
      end

      context "selector_re_s matching an indirect child" do
        before :each do
          re = Regexp.compile Rule.selector_re_s('foo#bar foo.bar')
        end

        it "should also match a direct child" do
          assert re =~ 'foo#bar/foo.bar'
        end

        it "should not match a direct child where the id and the class have been switched" do
          assert re !~ 'foo.bar/foo#bar'
        end

        it "should not match a direct child where an id has been traded for a class" do
          assert re !~ 'foo#bar/foo#bar'
        end

        it "should not match an element where a class has been traded for an id" do
          assert re !~ 'foo.bar/foo.bar'
        end

        it "should match a direct child as specified with a class added to the parent" do
          assert re =~ 'foo#bar.baz/foo.bar'
        end

        it "should match an a direct child as specified with a class added to the child" do
          assert re =~ 'foo#bar/foo.bar.baz'
        end

        it "should match a direct child as specified with classes added to both parent and child" do
          assert re =~ 'foo#bar.baz/foo.bar.baz'
        end

        it "should match a descendant separated by a simple tag" do
          assert re =~ 'foo#bar.baz/a/foo.bar.baz'
        end

        it "should match a descendant separated by a tag with an id" do
          assert re =~ 'foo#bar.baz/a#b/foo.bar.baz'
        end

        it "should match a descendant separated by a tag with a class" do
          assert re =~ 'foo#bar.baz/a.c/foo.bar.baz'
        end

        it "should match a descendant separated by a tag with an id and class" do
          assert re =~ 'foo#bar.baz/a#b.c/foo.bar.baz'
        end

        it "should match a descendant separated by an id" do
          # is this even possible?
          assert re =~ 'foo#bar.baz/#b/foo.bar.baz'
        end

        it "should match a descendant separated by a class" do
          # is this even possible?
          assert re =~ 'foo#bar.baz/.c/foo.bar.baz'
        end
      end

      context "parse" do
        it "should generate the expected data structure from the specified rules" do
          rules_text = <<-END
        		table label { border: solid; padding: 2pt }
        		.reverse { font.style: Bold; font.color: Gray; }
            .rotated { rotate: 270; origin-y: bottom; }
            .trouble { rotate: 30; origin-x: center; origin-y: middle; fill: White }
          END
          expected = [
            ["table label", {"border"=>"solid", "padding"=>"2pt"}],
            [".reverse", {"font.style"=>"Bold", "font.color"=>"Gray"}],
            [".rotated", {"rotate"=>"270", "origin_y"=>"bottom"}],
            [".trouble", {"rotate"=>"30", "origin_x"=>"center", "origin_y"=>"middle", "fill"=>"White"}]
          ]
          assert_equal(expected, Rule.parse(rules_text))
        end
      end
    end
  end
end
