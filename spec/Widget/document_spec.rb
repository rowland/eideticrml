require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Document do

      before :each do
        @doc = StdWidgetFactory.instance.make_widget('erml', nil)
        @doc.units('in')
        @legalland = @doc.styles.add('page', :id => 'legalland', :orientation => 'landscape', :size => 'legal')
      end

      context "make_widget" do
        it "should make a Document" do
          @doc.should be_instance_of(Document)
        end
      end

      context "page_style" do
        it "should default to :portrait/:letter" do
          @doc.style.orientation.should == :portrait
          @doc.style.size.should == :letter
        end

        it "should accept a named page style" do
          @doc.style('legalland')
          @doc.style.orientation.should == :landscape
          @doc.style.size.should == :legal
        end
      end

      context "width" do
        it "should default to 8.5" do
          @doc.width(:in).should == 8.5
        end

        it "should reflect width specified by page style" do
          @doc.style('legalland')
          @doc.width(:in).should == 14
        end
      end

      context "height" do
        it "should default to 11" do
          @doc.height(:in).should == 11
        end

        it "should reflect height specified by page style" do
          @doc.style('legalland')
          @doc.height(:in).should == 8.5
        end
      end
    end
  end
end
