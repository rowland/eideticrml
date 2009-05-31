require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Page do

      before :each do
        @doc = StdWidgetFactory.instance.make_widget('erml', nil)
        @doc.units('in')
        @legalland = @doc.styles.add('page', :id => 'legalland', :orientation => 'landscape', :size => 'legal')
        @page = StdWidgetFactory.instance.make_widget('page', @doc)
      end

      context "make_widget" do
        it "should make a page" do
          @page.should_not be(nil)
          @page.should be_instance_of(Page)
        end

        it "should have doc as it's parent" do
          @page.parent.should == @doc
        end
      end

      context "margin" do
        it "should have a zero-width margin, inherited from doc" do
          @doc.margin.should == [0,0,0,0]
          @page.margin.should == [0,0,0,0] # inherited
        end

        it "should inherit margins from doc" do
          @doc.margin('1')

          @page.margin.should == [72,72,72,72]
          @page.margin_top.should == 72
          @page.margin_right.should == 72
          @page.margin_bottom.should == 72
          @page.margin_left.should == 72

          @page.margin(:in).should == [1,1,1,1]
          @page.margin_top(:in).should == 1
          @page.margin_right(:in).should == 1
          @page.margin_bottom(:in).should == 1
          @page.margin_left(:in).should == 1
        end

        it "should allow margins to be overridden without affecting the document" do
          @doc.margin('1')
          @page.margin('2')

          @page.margin.should == [144,144,144,144] # in points
          @page.margin(:in).should == [2,2,2,2] # in specified units          
          @doc.margin(:in).should == [1,1,1,1] # unchanged
        end

        it "should allow margins to be set in initialize" do
          doc = Document.new
          page = Page.new(doc, :margin => '1') # initialize margin in constructor
          page.margin.should == [1,1,1,1]
        end
      end

      context "style" do
        it "should default to portrait/letter" do
          @page.style.orientation.should == :portrait
          @page.style.size.should == :letter
        end

        it "should accept a named page style" do
          @page.style('legalland')
          @page.style.orientation.should == :landscape
          @page.style.size.should == :legal
        end

        it "should support copying and updating without affecting the inherited style" do
          default_style = @page.style
          @page.style(:copy).orientation('landscape')
          @page.style.should_not == default_style
          @page.style.orientation.should == :landscape # changed
          @page.style.size.should == :letter # unchanged
        end
      end

      context "width" do
        it "should default to 8.5" do
          @page.width(:in).should == 8.5
        end

        it "should reflect width specified by page style" do
          @page.style('legalland')
          @page.width(:in).should == 14
        end
      end

      context "height" do
        it "should default to 11" do
          @page.height(:in).should == 11
        end

        it "should reflect height specifed by page style" do
          @page.style('legalland')
          @page.height(:in).should == 8.5
        end
      end

      context "orientation" do
        it "should default to :portrait" do
          @page.orientation.should == :portrait # default
        end

        it "should inherit from doc" do
          @doc.orientation(:landscape)
          @page.orientation.should == :landscape # inherited
          @doc.orientation(:portrait)
          @page.orientation.should == :portrait # inherited
        end

        it "should accept :landscape" do
          @page.orientation(:landscape)
          @page.orientation.should == :landscape # overridden
        end

        it "should accept :portrait" do
          @doc.orientation(:landscape) # just to be sure value is not inherited below
          @page.orientation(:portrait)
          @page.orientation.should == :portrait # overridden
        end
      end

      context "size" do
        it "should default to :letter" do
          @page.size.should == :letter # default
        end

        it "should inherit from doc" do
          @doc.size(:legal)
          @page.size.should == :legal # inherited
          @doc.size(:letter)
          @page.size.should == :letter # inherited
        end

        it "should accept :letter" do
          @page.size(:legal)
          @page.size.should == :legal # overridden
        end

        it "should accept :legal" do
          @page.size(:legal)
          @page.size(:letter)
          @page.size.should == :letter # overridden
        end
      end
    end
  end
end
