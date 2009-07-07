require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Container do

      before :each do
        @doc = StdWidgetFactory.instance.make_widget('erml', nil)
        @page = StdWidgetFactory.instance.make_widget('page', @doc)
        @centered = @doc.styles.add('para', :id => 'centered', :text_align => :center)
        @page.paragraph_style('centered')
        @div = StdWidgetFactory.instance.make_widget('div', @page)
      end

      context "make_widget" do
        it "should make a Container" do
          @div.should be_instance_of(Container)
        end

        it "should have its parent properly set" do
          @div.parent.should == @page
          @div.margin.should == [0, 0, 0, 0]
        end
      end

      context "cols" do
        it "should default to nil" do
          @div.cols.should == nil
        end

        it "should not accept values < 1" do
          @div.cols(0)
          @div.cols.should == nil
        end

        it "should accept positive integers" do
          @div.cols(3)
          @div.cols.should == 3
        end

        it "should accept positive integers as strings" do
          @div.cols('5')
          @div.cols.should == 5
        end
      end

      context "layout" do
        it "should default to nil" do
          @div.layout.should be(nil)
        end

        it "should accept names of registered layout managers" do
          %w(absolute flow hbox vbox table).each do |lm|
            @div.layout(lm)
            @div.layout.manager.should be_instance_of(LayoutManagers::LayoutManager.for_name(lm))
          end
        end

        it "should raise an ArgumentError if an invalid layout manager is specified" do
          lambda { @div.layout('bogus') }.should raise_error(ArgumentError)
        end
      end

      context "leaf?" do
        it "should be true when container is empty" do
          @div.leaf?.should be(true)
        end

        it "should be false when container has at least one child" do
          p = StdWidgetFactory.instance.make_widget('p', @div)
          @div.leaf?.should be(false)
        end
      end

      context "leaves" do
        it "should be 1 when container is empty" do
          @div.leaves.should == 1
        end

        it "should equal number of leaves contained" do
          p1 = StdWidgetFactory.instance.make_widget('p', @div)
          p2 = StdWidgetFactory.instance.make_widget('p', @div)
          d = StdWidgetFactory.instance.make_widget('div', @div)
          p3 = StdWidgetFactory.instance.make_widget('p', d)
          @div.leaves.should == 3
        end
      end

      context "more" do
        it "should default to true" do
          @div.more.should be(true)
          @page.more.should be(true)
        end

        it "should propagate down the tree" do
          @div.more(false)
          @div.more.should be(false)
          @page.more.should be(false)
        end
      end

      context "order" do
        it "should default to :rows" do
          @div.order.should == :rows
        end
        
        it "should accept :cols" do
          @div.order(:cols)
          @div.order.should == :cols
        end
        
        it "should accept :rows" do
          @div.order(:cols)
          @div.order(:rows)
          @div.order.should == :rows
        end
        
        it "should accept cols as string" do
          @div.order('cols')
          @div.order.should == :cols
        end
        
        it "should accept rows as string" do
          @div.order('rows')
          @div.order.should == :rows
        end
        
        it "should ignore bogus values" do
          @div.order('bogus')
          @div.order.should == :rows # unchanged
        end
      end

      context "overflow" do
        it "should default to nil (false)" do
          @div.overflow.should be(nil)
        end

        it "should accept true values" do
          @div.overflow(true)
          @div.overflow.should be(true)
        end

        it "should accept false values" do
          @div.overflow(false)
          @div.overflow.should be(false)
        end

        it "should accept true as string" do
          @div.overflow("true")
          @div.overflow.should be(true)
        end

        it "should accept false as string" do
          @div.overflow("false")
          @div.overflow.should be(false)
        end

        it "should accept other values and convert them to a string, evaluating as true" do
          @div.overflow(1)
          @div.overflow.should == '1'
        end
      end

      context "paragraph_style" do
        it "should default to page's paragraph style" do
          @div.paragraph_style.text_align.should == :center
        end
      end

      context "preferred_height" do
      end

      context "preferred_width" do
      end

      context "printed" do
        it "should default to nil (false)" do
          @div.printed.should be(nil)
        end

        it "should be true after doc is rendered" do
          @doc.to_s
          @div.printed.should be(true)
        end
        
        it "should behave the same for nested widgets" do
          p = StdWidgetFactory.instance.make_widget('p', @div)
          p.text "Hello"
          s = StdWidgetFactory.instance.make_widget('span', p)
          s.text "World"
          p.printed.should be(nil)
          @doc.to_s
          p.printed.should be(true)
        end
      end

      context "rows" do
        it "should default to nil" do
          @div.rows.should == nil
        end

        it "should ignore values < 1" do
          @div.rows(0)
          @div.rows.should == nil
        end

        it "should accept positive integers" do
          @div.rows(3)
          @div.rows.should == 3
        end

        it "should accept positive integers specifed as strings" do
          @div.rows('5')
          @div.rows.should == 5
        end
      end

      context "source" do
        it "should have the same children as the widget with the id specified" do
          l1 = StdWidgetFactory.instance.make_widget('label', @div)
          l2 = StdWidgetFactory.instance.make_widget('label', @div)
          @div.id('d1')
          d2 = StdWidgetFactory.instance.make_widget('div', @page)
          d2.source('d1')
          d2.children.should == @div.children
        end
      end
    end
  end
end
