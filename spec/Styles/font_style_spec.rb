require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe FontStyle do
      before :each do
        @font_style = Style.for_name('font').new(nil)
      end

      context "initialize" do
        it "should make a FontStyle" do
          @font_style.should be_kind_of(FontStyle)
        end
      end

      context "color" do
        it "should default to 0 (black)" do
          @font_style.color.should == 0
        end
        
        it "should accept a named color" do
          @font_style.color 'Red'
          @font_style.color.should == 'Red'
        end
      end

      context "name" do
        it "should default to Helvetica" do
          @font_style.name.should == 'Helvetica'
        end
        
        it "should accept a named font style" do
          @font_style.name 'bigred'
          @font_style.name.should == 'bigred'
        end
      end

      context "size" do
        it "should default to 12" do
          @font_style.size.should == 12
        end
        
        it "should accept a float value" do
          @font_style.size 14.5
          @font_style.size.should == 14.5
        end
      end

      context "strikeout" do
        it "should default to nil (false)" do
          @font_style.strikeout.should be(nil)
        end
        
        it "should accept true" do
          @font_style.strikeout(true)
          @font_style.strikeout.should be(true)
        end
        
        it "should accept false" do
          @font_style.strikeout(false)
          @font_style.strikeout.should be(false)
        end
        
        it "should accept true specified as a string" do
          @font_style.strikeout("true")
          @font_style.strikeout.should be(true)
        end
        
        it "should accept false specified as a string" do
          @font_style.strikeout("false")
          @font_style.strikeout.should be(false)
        end
      end

      context "style" do
        it "should default to blank" do
          @font_style.style.should == ''
        end
        
        it "should accept a string value" do
          @font_style.style 'Italic'
          @font_style.style.should == 'Italic'
        end
      end

      context "encoding" do
        it "should default to WinAnsiEncoding" do
          @font_style.encoding.should == 'WinAnsiEncoding'
        end
        
        it "should accept a string value" do
          @font_style.encoding 'StandardEncoding'
          @font_style.encoding.should == 'StandardEncoding'
        end
      end

      context "sub_type" do
        it "should default to Type1" do
          @font_style.sub_type.should == 'Type1'
        end
        
        it "should accept a string value" do
          @font_style.sub_type 'TrueType'
          @font_style.sub_type.should == 'TrueType'
        end
      end

      context "underline" do
        it "should default to nil (false)" do
          @font_style.underline.should be(nil)
        end
        
        it "should accept true" do
          @font_style.underline(true)
          @font_style.underline.should be(true)
        end
        
        it "should accept false" do
          @font_style.underline(false)
          @font_style.underline.should be(false)
        end
        
        it "should accept true specifed as a string" do
          @font_style.underline("true")
          @font_style.underline.should be(true)
        end
        
        it "should accept false specified as a string" do
          @font_style.underline("false")
          @font_style.underline.should be(false)
        end
      end

      context "weight" do
        it "should default to nil" do
          @font_style.weight.should be(nil)
        end
        
        it "should accept a string value" do
          @font_style.weight('Bold')
          @font_style.weight.should == 'Bold'
        end
      end
    end
  end
end
