require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe BrushStyle do
      before :each do
        @brush_style = Style.for_name('brush').new(nil)
      end

      context "initialize" do
        it "should make a BrushStyle" do
          @brush_style.should be_kind_of(BrushStyle)
        end
      end

      context "color" do
        it "should default to 0 (black)" do
          @brush_style.color.should == 0
        end

        it "should accept a named color" do
          @brush_style.color 'Blue'
          @brush_style.color.should == 'Blue'
        end

        it "should accept a numeric value representing an RGB color" do
          @brush_style.color 0xFF0000
          @brush_style.color.should == 0xFF0000
        end

        it "should accept an HTML-style string value representing an RGB color" do
          @brush_style.color "#EEEEEE"
          @brush_style.color.should == 0xEEEEEE
        end

        it "should accept an abbreviated HTML-style string value representing an RGB color" do
          @brush_style.color "#999"
          @brush_style.color.should == 0x999999
        end
      end
    end
  end
end
