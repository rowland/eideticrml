require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Rules
    describe Rule do
      context "item_re_s regex's" do
        it "should generate an expression matching a tag" do
          Rule.item_re_s('foo').should == 'foo(#\\w+)?(\\.\\w+)*'
        end

        it "should generate an expression matching a tag with an id" do
          Rule.item_re_s('foo#bar').should == 'foo#bar(\\.\\w+)*'
        end

        it "should generate an expression matching a tag with a class" do
          Rule.item_re_s('foo.bar').should == 'foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*'
        end

        it "should generate an expression matching an id" do
          Rule.item_re_s('#bar').should == '\w+#bar(\\.\\w+)*'
        end

        it "should generate an expression matching a class" do
          Rule.item_re_s('.bar').should == '\w+(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*'
        end
      end

      context "group_re_s regex's" do
        it "should generate an expression matching a tag with a class that is the direct child of a tag with an id" do
          Rule.group_re_s('foo#bar>foo.bar').should == 'foo#bar(\\.\\w+)*\\/foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*'
        end
      end

      context "selector_re_s regex's" do
        it "should generate an expression matching a tag with a class that is a descendent of a tag with an id" do
          Rule.selector_re_s('foo#bar foo.bar').should == 'foo#bar(\\.\\w+)*\\/([^\\/]+\\/)*foo(#\\w+)?(\\.\\w+)*\\.bar(\\.\\w+)*$'
        end

        it "should generate an expression matching any of a comma-delimited list of tags" do
          Rule.selector_re_s('foo, bar').should == '(foo(#\\w+)?(\\.\\w+)*$|bar(#\\w+)?(\\.\\w+)*$)'
        end
      end

      context "selector_re_s matching a tag" do
        before :each do
          @re = Regexp.compile Rule.selector_re_s('foo')
        end

        it "should match a tag" do
          @re.should =~ 'foo'
        end

        it "should match a tag with an id" do
          @re.should =~ 'foo#bar'
        end

        it "should match a tag with a class" do
          @re.should =~ 'foo.bar'
        end

        it "should match a tag with an id and a class" do
          @re.should =~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching either of two tags" do
        before :each do
          @re = Regexp.compile Rule.selector_re_s('foo, bar')
        end

        it "should match the first tag" do
          @re.should =~ 'foo'
        end

        it "should match the first tag with an id" do
          @re.should =~ 'foo#bar'
        end

        it "should match the second tag" do
          @re.should =~ 'bar'
        end

        it "shold match the second tag with a class" do
          @re.should =~ 'bar.baz'
        end

        it "should not match an unspecified tag" do
          @re.should_not =~ 'baz'
        end
      end

      context "selector_re_s matching an id" do
        before :each do
          @re = Regexp.compile Rule.selector_re_s('#bar')
        end

        it "should not match just a simple tag" do
          @re.should_not =~ 'foo'
        end

        it "should match a tag with the specified id" do
          @re.should =~ 'foo#bar'
        end

        it "should not match a tag with an id but no class" do
          @re.should_not =~ 'foo.bar'
        end

        it "should match a tag with the specified id and a class" do
          @re.should =~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching a class" do
        before :each do
          @re = Regexp.compile Rule.selector_re_s('.bar')
        end

        it "should not match just a simple tag" do
          @re.should_not =~ 'foo'
        end

        it "should not match a tag with an id but no class" do
          @re.should_not =~ 'foo#bar'
        end

        it "should match a tag with the specified class" do
          @re.should =~ 'foo.bar'
        end

        it "should not match a tag with an id named the same as the specified class" do
          @re.should_not =~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching another class" do
        before :each do
          @re = Regexp.compile Rule.selector_re_s('.baz')
        end

        it "should not match just a simple tag" do
          @re.should_not =~ 'foo'
        end

        it "should not match a tag with an id but no class" do
          @re.should_not =~ 'foo#bar'
        end

        it "should not match a tag with the wrong class" do
          @re.should_not =~ 'foo.bar'
        end

        it "should match a tag with an id and the specified class" do
          @re.should =~ 'foo#bar.baz'
        end
      end

      context "selector_re_s matching a direct child" do
        before :each do
          @re = Regexp.compile Rule.selector_re_s('foo#bar>foo.bar')
        end

        it "should match an element exactly as specified" do
          @re.should =~ 'foo#bar/foo.bar'
        end

        it "should not match an element where the id and the class have been switched" do
          @re.should_not =~ 'foo.bar/foo#bar'
        end

        it "should not match an element where an id has been traded for a class" do
          @re.should_not =~ 'foo#bar/foo#bar'
        end

        it "should not match an element where a class has been traded for an id" do
          @re.should_not =~ 'foo.bar/foo.bar'
        end

        it "should match an element as specified with a class added to the parent" do
          @re.should =~ 'foo#bar.baz/foo.bar'
        end

        it "should match an element as specified with a class added to the child" do
          @re.should =~ 'foo#bar/foo.bar.baz'
        end

        it "should match an element as specified with classes added to both parent and child" do
          @re.should =~ 'foo#bar.baz/foo.bar.baz'
        end
      end

      context "selector_re_s matching an indirect child" do
        before :each do
          @re = Regexp.compile Rule.selector_re_s('foo#bar foo.bar')
        end

        it "should also match a direct child" do
          @re.should =~ 'foo#bar/foo.bar'
        end

        it "should not match a direct child where the id and the class have been switched" do
          @re.should_not =~ 'foo.bar/foo#bar'
        end

        it "should not match a direct child where an id has been traded for a class" do
          @re.should_not =~ 'foo#bar/foo#bar'
        end

        it "should not match an element where a class has been traded for an id" do
          @re.should_not =~ 'foo.bar/foo.bar'
        end

        it "should match a direct child as specified with a class added to the parent" do
          @re.should =~ 'foo#bar.baz/foo.bar'
        end

        it "should match an a direct child as specified with a class added to the child" do
          @re.should =~ 'foo#bar/foo.bar.baz'
        end

        it "should match a direct child as specified with classes added to both parent and child" do
          @re.should =~ 'foo#bar.baz/foo.bar.baz'
        end

        it "should match a descendant separated by a simple tag" do
          @re.should =~ 'foo#bar.baz/a/foo.bar.baz'
        end

        it "should match a descendant separated by a tag with an id" do
          @re.should =~ 'foo#bar.baz/a#b/foo.bar.baz'
        end

        it "should match a descendant separated by a tag with a class" do
          @re.should =~ 'foo#bar.baz/a.c/foo.bar.baz'
        end

        it "should match a descendant separated by a tag with an id and class" do
          @re.should =~ 'foo#bar.baz/a#b.c/foo.bar.baz'
        end

        it "should match a descendant separated by an id" do
          # is this even possible?
          @re.should =~ 'foo#bar.baz/#b/foo.bar.baz'
        end

        it "should match a descendant separated by a class" do
          # is this even possible?
          @re.should =~ 'foo#bar.baz/.c/foo.bar.baz'
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
          Rule.parse(rules_text).should == expected
        end
      end
    end
  end
end
