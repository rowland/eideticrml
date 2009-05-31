require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Rectangle do
      before :each do
        @page = Page.new(nil, :units => :pt)
      end

      context "corners" do
        it "should default to nil" do
          rect = Rectangle.new(@page)
          rect.corners.should == nil
        end

        it "should accept 1 value" do
          rect = Rectangle.new(@page, :corners => '1')
          rect.corners.should == [1]
        end

        it "should accept 2 values" do
          rect = Rectangle.new(@page, :corners => '1,2')
          rect.corners.should == [1,2]
        end

        it "should accept 4 values" do
          rect = Rectangle.new(@page, :corners => '1,2,3,4')
          rect.corners.should == [1,2,3,4]
        end

        it "should accept 8 values" do
          rect = Rectangle.new(@page, :corners => '1,2,3,4,5,6,7,8')
          rect.corners.should == [1,2,3,4,5,6,7,8]
        end

        it "should ignore an invalid number of values" do
          rect = Rectangle.new(@page, :corners => '1,2,3')
          rect.corners.should == nil
        end
      end
    end
  end
end
