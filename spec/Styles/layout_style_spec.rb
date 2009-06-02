require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe LayoutStyle do
      before :each do
        @layout_style = Style.for_name('layout').new(nil)
      end

      context "initialize" do
        it "should make a LayoutStyle" do
          @layout_style.should be_kind_of(LayoutStyle)
        end
      end

      context "units" do
        it "should default to pt" do
          @layout_style.units.should == :pt
        end
      end

      context "padding" do
        it "should default to 0" do
          @layout_style.padding.should == 0
        end

        it "should accept a numeric value in the default units" do
          @layout_style.padding 5
          @layout_style.padding.should == 5
        end

        it "should accept a numeric value with specified units" do
          @layout_style.padding 2, :cm
          @layout_style.padding.should == 56.7
          @layout_style.padding(:cm).should == 2

          @layout_style.padding 1, 'in'
          @layout_style.padding(:in).should == 1
          @layout_style.padding.should == 72
        end

        it "should accept a string with a numeric value and units suffix" do
          @layout_style.padding '5pt'
          @layout_style.padding.should == 5

          @layout_style.padding '2cm'
          @layout_style.padding(:cm).should == 2
          @layout_style.padding.should == 56.7

          @layout_style.padding '1.25in'
          @layout_style.padding(:in).should == 1.25
        end
      end

      context "hpadding" do
        it "should default ot 0" do
          @layout_style.hpadding.should == 0
        end

        it "should accept a numeric value in the default units" do
          @layout_style.hpadding 5
          @layout_style.hpadding.should == 5
        end

        it "should accept a numeric value with specified units" do
          @layout_style.hpadding 2, :cm
          @layout_style.hpadding(:cm).should == 2

          @layout_style.hpadding 1, 'in'
          @layout_style.hpadding(:in).should == 1
          @layout_style.hpadding.should == 72
        end

        it "should accept a string with a numeric value and units suffix" do
          @layout_style.hpadding '5pt'
          @layout_style.hpadding.should == 5

          @layout_style.hpadding '2cm'
          @layout_style.hpadding(:cm).should == 2
          @layout_style.hpadding.should == 56.7

          @layout_style.hpadding '1.25in'
          @layout_style.hpadding(:in).should == 1.25
        end
      end

      context "vpadding" do
        it "should default to 0" do
          @layout_style.vpadding.should == 0
        end

        it "should accept a numeric value in the default units" do
          @layout_style.vpadding 5
          @layout_style.vpadding.should == 5
        end

        it "should accept a numeric value withe specified units" do
          @layout_style.vpadding 2, :cm
          @layout_style.vpadding(:cm).should == 2

          @layout_style.vpadding 1, 'in'
          @layout_style.vpadding(:in).should == 1
          @layout_style.vpadding.should == 72
        end

        it "should accept a string with a numeric value and units suffix" do
          @layout_style.vpadding '5pt'
          @layout_style.vpadding.should == 5

          @layout_style.vpadding '2cm'
          @layout_style.vpadding(:cm).should == 2
          @layout_style.vpadding.should == 56.7

          @layout_style.vpadding '1.25in'
          @layout_style.vpadding(:in).should == 1.25
        end
      end

      context "manager" do
        it "should default to nil" do
          @layout_style.manager.should be(nil)
        end

        it "should accept and lookup a registered layout manager" do
          @layout_style.manager('absolute')
          @layout_style.manager.should be_kind_of(EideticRML::LayoutManagers::AbsoluteLayout)
        end
      end
    end
  end
end
