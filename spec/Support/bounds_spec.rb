require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Support
    describe Bounds do
      context "sides" do
        it "should default to nil" do
          b = Support::Bounds.new
          b.left.should be(nil)
          b.top.should be(nil)
          b.right.should be(nil)
          b.bottom.should be(nil)
        end

        it "should be initialized with parameters" do
          b = Support::Bounds.new(3,5,7,11)
          b.left.should == 3
          b.top.should == 5
          b.right.should == 7
          b.bottom.should == 11
        end
      end

      context "width" do
        it "should equal right - left" do
          b = Support::Bounds.new(3,5,7,11)
          b.width.should == 4
        end
      end

      context "height" do
        it "should equal bottom - top" do
          b = Support::Bounds.new(3,5,7,11)
          b.height.should == 6
        end
      end
    end
  end
end
