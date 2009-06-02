require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe PageStyle do
      before :each do
        @page_style = Style.for_name('page').new(nil)
      end

      context "initialize" do
        it "should make a PageStyle" do
          @page_style.should be_kind_of(PageStyle)
        end
      end

      context "size" do
        it "should default to :letter" do
          @page_style.size.should == :letter
        end

        it "should ignore bogus values" do
          @page_style.size 'bogus'
          @page_style.size.should == :letter
        end

        it "should accept symbols identifying predefined page sizes" do
          @page_style.size :legal
          @page_style.size.should == :legal
        end

        it "should accept strings identifying predefined page sizes and convert to symbol" do
          ['A4', 'B5', 'C5'].each do |size|
            @page_style.size size
            @page_style.size.should == size.to_sym
          end
        end
      end

      context "orientation" do
        it "should default to :portrait" do
          @page_style.orientation.should == :portrait
        end

        it "should accept :landscape" do
          @page_style.orientation :landscape
          @page_style.orientation.should == :landscape
        end

        it "should accept string values corresponding to symbols" do
          ['portrait', 'landscape'].each do |orientation|
            @page_style.orientation orientation
            @page_style.orientation.should == orientation.to_sym
          end
        end

        it "should ignore bogus values" do
          @page_style.orientation 'bogus'
          @page_style.orientation.should == :portrait
        end
      end

      context "height" do
        it "should default to letter height" do
          @page_style.height.should == 792
          @page_style.height(:in).should == 11
        end
      end

      context "width" do
        it "should default to letter width" do
          @page_style.width.should == 612
          @page_style.width(:in).should == 8.5
        end
      end
    end
  end
end
