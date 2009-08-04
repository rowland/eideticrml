require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Circle do
      before :each do
        @doc = Document.new(nil)
        @page = Page.new(@doc, :margin => 1, :layout => 'absolute')
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

        it "should be sized to fit contents if not otherwise specified" do
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @doc.to_s
          @circle.width.should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) * 2 # 3.16227766016838
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

        it "should be sized to fit contents if not otherwise specified" do
          @circle.layout('flow')
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @doc.to_s
          @circle.height.should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) * 2 # 3.16227766016838
        end
      end

      context "preferred_width" do
        it "should equal width when width is set" do
          @circle.width(144)
          @circle.preferred_width(nil).should == 144
        end

        it "should fit contents if not otherwise specified" do
          @circle.layout('flow')
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @circle.preferred_width(nil).should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) * 2 # 3.16227766016838
        end

        it "should match height when only height has been set" do
          @circle.height(72)
          @circle.preferred_width(nil).should == 72
        end
      end

      context "preferred_height" do
        it "should equal height when height is set" do
          @circle.height(144)
          @circle.preferred_height(nil).should == 144
        end

        it "should fit contents if not otherwise specified" do
          @circle.layout('flow')
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @circle.preferred_height(nil).should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) * 2 # 3.16227766016838
        end

        it "should match width when only width has been set" do
          @circle.width(72)
          @circle.preferred_height(nil).should == 72
        end
      end

      context "default_padding_top" do
        it "should be sized to fit rectangular contents inside border" do
          @circle.layout('flow')
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @doc.to_s
          @circle.default_padding_top.should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) - 1/2.0 # 1.08113883008419
        end
      end

      context "default_padding_right" do
        it "should be sized to fit rectangular contents inside border" do
          @circle.layout('flow')
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @doc.to_s
          @circle.default_padding_right.should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) - 3/2.0 # 0.0811388300841898
        end
      end

      context "default_padding_bottom" do
        it "should be sized to fit rectangular contents inside border" do
          @circle.layout('flow')
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @doc.to_s
          @circle.default_padding_bottom.should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) - 1/2.0 # 1.08113883008419
        end
      end

      context "default_padding_left" do
        it "should be sized to fit rectangular contents inside border" do
          @circle.layout('flow')
          rect = Widget.new(@circle, :width => 3, :height => 1)
          @doc.to_s
          @circle.default_padding_left.should == Math.sqrt((3/2.0) ** 2 + (1/2.0) ** 2) - 3/2.0 # 0.0811388300841898
        end
      end
    end
  end
end
