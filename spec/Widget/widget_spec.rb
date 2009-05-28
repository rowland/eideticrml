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
    end
  end
end
