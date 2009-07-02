require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Circle do
      before :each do
        @doc = Widgets::Document.new(nil)
        @page = Widgets::Page.new(@doc, :margin => 1, :layout => 'absolute')
        @circle = Circle.new(@page)
      end

      context "x" do
        it "should default to nil" do
          @circle.x.should be(nil)
        end

        it "should be set midway between left and right borders before printing" do
          @circle.left 4
          @circle.width 2

          @circle.x.should be(nil)
          @circle.position.should == :static

          @doc.to_s
          @circle.x.should == 5
        end

        it "should be offset by half the left margin" do
          @circle.left 4
          @circle.width 4
          @circle.margin_left 1

          @doc.to_s
          @circle.x.should == 6.5
        end

        it "should be offset by half the right margin" do
          @circle.left 4
          @circle.width 4
          @circle.margin_right 1

          @doc.to_s
          @circle.x.should == 5.5
        end
      end

      context "y" do
        it "should default to nil" do
          @circle.y.should be(nil)
        end

        it "should be set midway between top and bottom borders before printing" do
          @circle.top 4
          @circle.height 2

          @circle.top.should == 4
          @circle.height.should == 2
          @circle.y.should be(nil)
          @circle.position.should == :static

          @doc.to_s
          @circle.top.should == 4
          @circle.height.should == 2
          @circle.y.should == 5
        end

        it "should be offset by half the top margin" do
          @circle.top 4
          @circle.height 4
          @circle.margin_top 1

          @doc.to_s
          @circle.y.should == 6.5
        end

        it "should be offset by half the bottom margin" do
          @circle.top 4
          @circle.height 4
          @circle.margin_bottom 1

          @doc.to_s
          @circle.y.should == 5.5
        end
      end

      context "r" do
        it "should be half the minimum of width or height" do
          @circle.left 1
          @circle.width 6
          @circle.top 1
          @circle.height 6

          @doc.to_s
          @circle.r.should == 3
        end

        it "should not be affected by padding" do
          @circle.left 1
          @circle.width 6
          @circle.top 1
          @circle.height 6

          @circle.padding 1

          @doc.to_s
          @circle.r.should == 3
        end

        it "should be reduced by margin" do
          @circle.left 1
          @circle.width 6
          @circle.top 1
          @circle.height 6

          @circle.margin 1

          @doc.to_s
          @circle.r.should == 2
        end
      end

      context "width" do
        it "should default to nil" do
          @circle.width.should be(nil)
        end

        it "should be 2 * r" do
          @circle.r 3
          @circle.width.should == 6
        end
      end

      context "height" do
        it "should default to nil" do
          @circle.height.should be(nil)
        end

        it "should be 2 * r" do
          @circle.r 3
          @circle.height.should == 6
        end
      end
    end
  end
end
