require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe PenStyle do
      before :each do
        @pen_style = Style.for_name('pen').new(nil)
      end

      context "initialize" do
        it "should be a PenStyle" do
          @pen_style.should be_a_kind_of(PenStyle)
        end
      end

      context "units" do
        it "should default to pt" do
          @pen_style.units.should == :pt
        end
      end

      context "width" do
        it "should default to 0" do
          @pen_style.width.should == 0
        end

        it "should accept integer values, retaining default units" do
          @pen_style.width 123
          @pen_style.width.should == 123
          @pen_style.units.should == :pt
        end

        it "should accept float values, retaining default units" do
          @pen_style.width 456.789
          @pen_style.width.should == 456.789
          @pen_style.units.should == :pt
        end

        it "should accept string values, convert to a numeric value, retaining default units" do
          @pen_style.width '123'
          @pen_style.width.should == 123
          @pen_style.units.should == :pt
        end

        it "should accept string values with unit suffix" do
          @pen_style.width '2cm'
          @pen_style.width.should == 56.7
          @pen_style.width(:cm).should == 2
        end
      end

      context "pattern" do
        it "should default to solid" do
          @pen_style.pattern.should == :solid
        end
        
        it "should accept dotted" do
          @pen_style.pattern :dotted
          @pen_style.pattern.should == :dotted
        end
        
        it "should accept dashed" do
          @pen_style.pattern 'dashed'
          @pen_style.pattern.should == :dashed
        end
        
        it "should accept an arbitrary PDF line pattern" do
          @pen_style.pattern '[1, 10]'
          @pen_style.pattern.should == '[1, 10]'
        end
      end

      context "color" do
        it "should default to 0 (black)" do
          @pen_style.color.should == 0
        end

        it "should accept named colors" do
          @pen_style.color 'Blue'
          @pen_style.color.should == 'Blue'
        end

        it "should accept numeric values representing RGB colors" do
          @pen_style.color 0xFF0000
          @pen_style.color.should == 0xFF0000
        end
      end

      context "cap" do
        it "should default to butt_cap" do
          @pen_style.cap.should == :butt_cap
        end
        
        it "should accept round_cap" do
          @pen_style.cap 'round_cap'
          @pen_style.cap.should == :round_cap
        end
        
        it "should accept projecting_square_cap" do
          @pen_style.cap 'projecting_square_cap'
          @pen_style.cap.should == :projecting_square_cap
        end
        
        it "should accept butt_cap" do
          @pen_style.cap 'projecting_square_cap'
          @pen_style.cap 'butt_cap'
          @pen_style.cap.should == :butt_cap
        end
        
        it "should ignore bogus cap styles" do
          @pen_style.cap 'bogus_cap_style'
          @pen_style.cap.should == :butt_cap # unchanged
        end
      end
    end
  end
end
