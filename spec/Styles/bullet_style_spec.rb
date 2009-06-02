require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe BulletStyle do
      before :each do
        @styles = StyleCollection.new
        @font_style = @styles.add('font', :id => 'f1', :name => 'Courier', :size => 13)
        @bullet_style = @styles.add('bullet', :id => 'b1')
      end

      context "font" do
        it "should default to nil" do
          @bullet_style.font.should be(nil)
        end

        it "should accept a valid font style id" do
          @bullet_style.font('f1')
          @bullet_style.font.should == @font_style
        end
      end

      context "text" do
        it "should default to nil" do
          @bullet_style.text.should be(nil)
        end

        it "should accept a string value" do
          @bullet_style.text("*")
          @bullet_style.text.should == "*"
        end
      end

      context "width" do
        it "should accept default to 0.5 inches" do
          @bullet_style.width.should == 36
          @bullet_style.width(:in).should == 0.5
        end

        it "should accept a numeric value in a string with unit suffix" do
          @bullet_style.width('18pt')
          @bullet_style.width.should == 18
          @bullet_style.width(:in).should == 0.25
        end
      end

      context "units" do
        it "should default to pt" do
          @bullet_style.units.should == :pt
        end

        it "should accept a value unit specifed as a string" do
          @bullet_style.units('cm')
          @bullet_style.units.should == :cm
        end

        it "should use alternate specified units when a width is set" do
          @bullet_style.units('cm')
          @bullet_style.width('1')
          @bullet_style.width.should == 28.35
          @bullet_style.width(:cm).should == 1
        end
      end
    end
  end
end
