require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Widget do
      before :each do
        @doc = StdWidgetFactory.instance.make_widget('erml', nil)
        @alt = @doc.styles.add('font', :id => 'alt', :name => 'Times', :size => 10, :style => 'Bold', :encoding => 'CP1252', :color => '0xFFFFFF')
        @blue_dash = @doc.styles.add('pen', :id => 'blue_dash', :color => 'Blue', :width => '4pt', :pattern => 'dashed')
        @dotted = @doc.styles.for_id('dotted')
        @battleship = @doc.styles.add('brush', :id => 'battleship', :color => 'LightSteelBlue')
        @page = StdWidgetFactory.instance.make_widget('page', @doc)
        @widget = Widget.new(@page)
      end

      context "setup" do
        it "should create some widgets" do
          @widget.should_not == nil
          @page.should_not == nil
          @doc.should_not == nil
        end
      end

      context "@page" do
        it "should be @widget.parent" do
          @page.should == @widget.parent
        end
      end

      context "align" do
        it "should default to nil" do
          @widget.align.should == nil
        end

        it "should allow assignment of legitimate values" do
          [:top, :right, :bottom, :left].each do |align|
            @widget.align(align)
            @widget.align.should == align
          end
        end

        it "should remain unchanged when a bogus value is assigned" do
          @widget.align(:left)
          @widget.align(:bogus)
          @widget.align.should == :left
        end
      end

      context "position" do
        it "should default to :static" do
          @widget.position.should == :static
        end

        it "should allow assignment of :relative, :absolute and :static symbols" do
          @widget.position(:relative)
          @widget.position.should == :relative
          @widget.position(:absolute)
          @widget.position.should == :absolute
          @widget.position(:static)
          @widget.position.should == :static
        end

        it "should allow assignment of 'static', 'relative' and 'absolute' and convert them to symbols" do
          @widget.position("relative")
          @widget.position.should == :relative
          @widget.position("absolute")
          @widget.position.should == :absolute
          @widget.position("static")
          @widget.position.should == :static
        end

        it "should ignore assignment of bogus values" do
          @widget.position(:bogus)
          @widget.position.should == :static
          @widget.position("bogus")
          @widget.position.should == :static
        end

        it "should change from static to relative when top is set with string value" do
          @widget.top "7"
          @widget.position.should == :relative
        end

        it "should change from static to relative when right is set with string" do
          @widget.right "7"
          @widget.position.should == :relative
        end

        it "should change from static to relative when bottom is set with string value" do
          @widget.bottom "7"
          @widget.position.should == :relative
        end

        it "should change from static to relative when left is set with string value" do
          @widget.left "7"
          @widget.position.should == :relative
        end
      end

      context "tag" do
        it "should default to nil" do
          @widget.tag.should == nil
        end

        it "should ignore bogus values" do
          @widget.tag(' !@#$%')
          @widget.tag.should == nil
        end

        it "should allow valid values" do
          @widget.tag('widget')
          @widget.tag.should == 'widget'
        end
      end
      
      context "id" do
        it "should default to nil" do
          @widget.id.should == nil
        end
        
        it "should ignore bogus values" do
          @widget.id(' !@#$%')
          @widget.id.should == nil
        end
        
        it "should allow valid values" do
          @widget.id('widget')
          @widget.id.should == 'widget'
        end
      end

      context "klass" do
        it "should default to nil" do
          @widget.klass.should == nil
        end
        
        it "should ignore bogus values" do
          @widget.klass(' !@#$%')
          @widget.klass.should == nil
        end
        
        it "should allow valid values" do
          @widget.klass('foo bar')
          @widget.klass.should == 'foo bar'
        end
      end

      context "selector_tag" do
        it "should have expected values for @doc and @page" do
          @doc.selector_tag.should == 'erml'
          @page.selector_tag.should == 'page'
        end
        
        it "should start with a default value and change as id and class are assigned" do
          p1 = StdWidgetFactory.instance.make_widget('p', @page)
          p1.selector_tag.should == 'p'
          p1.id('id')
          p1.selector_tag.should == 'p#id'
          p1.klass('class')
          p1.selector_tag.should == 'p#id.class'

          p2 = StdWidgetFactory.instance.make_widget('p', @page)
          p2.klass('class')
          p2.selector_tag.should == 'p.class'
        end
      end
      
      context "path" do
        it "should have expected values for @doc and @page" do
          @doc.path.should == 'erml'
          @page.path.should == 'erml/page'
        end
        
        it "should start with a default value and change as id and class are assigned" do
          p1 = StdWidgetFactory.instance.make_widget('p', @page)
          p1.path.should == 'erml/page/p'
          p1.id('id')
          p1.path.should == 'erml/page/p#id'
          p1.klass('class')
          p1.path.should == 'erml/page/p#id.class'

          p2 = StdWidgetFactory.instance.make_widget('p', @page)
          p2.klass('class')
          p2.path.should == 'erml/page/p.class'
        end
      end
      
      context "top" do
        it "should be settable with default units" do
          @widget.top("18")
          @widget.top.should == 18
          @widget.top(:in).should == 0.25
        end

        it "should be added to height to determine bottom" do
          @widget.top("0.25in")
          @widget.height("7in")
          @widget.bottom(:in).should == 7.25
        end

        it "should treat negative values as relative to container bottom" do
          @widget.top("-2in")
          @widget.top(:in).should == 9
        end
      end

      context "right" do
        it "should be settable with default units" do
          @widget.right("36")
          @widget.right.should == 36
          @widget.right(:in).should == 0.5
        end
        
        it "should allow width to be subtracted to determine left" do
          @widget.right(342)
          @widget.right(:in).should == 4.75
          @widget.width(1, :in)
          @widget.left(:in).should == 3.75
        end
        
        it "should treat negative values as relative to container right" do
          @widget.right("-1in")
          @widget.width(1, :in)
          @widget.left(:in).should == 6.5
        end
      end

      context "bottom" do
        it "should be settable with default units" do
          @widget.bottom("54")
          @widget.bottom.should == 54
          @widget.bottom(:in).should == 0.75
        end
        
        it "should allow height to be subtracted to determine top" do
          @widget.bottom(54)
          @widget.height(36)
          @widget.top.should == 18
        end
      
        it "should treat negative values as relative to container bottom" do
          @widget.bottom("-144")
          @widget.height("72")
          @widget.top.should == 576
          @widget.top(:in).should == 8
        end
      end

      context "left" do
        it "should be settable with default units" do
          @widget.left("72")
          @widget.left.should == 72
          @widget.left(:in).should == 1
        end

        it "should be added to width to determine right" do
          @widget.left("1in")
          @widget.width("7in")
          @widget.right(:in).should == 8
        end

        it "should treat negative values as relative to container width" do
          @widget.left("-2in")
          @widget.left(:in).should == 6.5
        end
      end

      context "widget in div" do
        before :each do
          @div = StdWidgetFactory.instance.make_widget('div', @page)
          @div.position(:absolute)
          @div.top "1in"
          @div.left "1in"
          @div.width "2in"
          @div.height "2in"
        end

        context "top" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.top("0.5in")
            w.top.should == 108
            w.top(:in).should == 1.5
          end
        end

        context "right" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.right("-0.5in")
            w.right.should == 180
            w.right(:in).should == 2.5
          end
        end

        context "bottom" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.bottom("-0.5in")
            w.bottom.should == 180
            w.bottom(:in).should == 2.5
          end
        end

        context "left" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.left("0.5in")
            w.left.should == 108
            w.left(:in).should == 1.5
          end
        end
      end

      context "units" do
        it "should default to :pt" do
          @doc.units.should == :pt
          @widget.units.should == :pt
        end

        it "should should be inherited from container" do
          @doc.units(:in)
          @doc.units.should == :in
          @widget.units.should == :in
        end

        it "should allow inherited value to be overridden" do
          @widget.units(:in)
          @widget.units.should == :in
          @doc.units.should == :pt
        end
      end
    end
  end
end
