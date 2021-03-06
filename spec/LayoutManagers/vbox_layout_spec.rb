require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe VBoxLayout do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
        @div = Widgets::Container.new(@page, :layout => 'absolute', :width => '100%', :height => '100%')

        @style = Styles::LayoutStyle.new(nil)
        @style.padding(5)
        @lm = LayoutManager.for_name('vbox').new(@style)
      end

      context "initialize" do
        it "should make an VBoxLayout instance" do
          @lm.should be_kind_of(VBoxLayout)
        end
      end

      # ------
      # | p1 |
      # |----|
      # | p2 |
      # ------
      context "grid" do
        it "should place all widgets in one column" do
          p1 = Widgets::Paragraph.new(@div)
          p2 = Widgets::Paragraph.new(@div)
          grid = @lm.grid(@div)
          grid.cols.should == 1
          grid.rows.should == 2
          grid[0, 0].should == p1
          grid[0, 1].should == p2
        end
      end

      context "preferred_width" do
        it "should return zero if the container is empty" do
          grid = @lm.grid(@div)
          @lm.preferred_width(grid, nil).should == 0
        end

        it "should return the max widget width" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w1.width(10, :pt)
          w2.width(20, :pt)
          # w1.preferred_width(nil).should == 10
          # w2.preferred_width(nil).should == 20
          grid = @lm.grid(@div)
          @lm.preferred_width(grid, nil).should == 20
        end

        it "should return nil if the width of any widget is unspecified" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w3 = Widgets::Widget.new(@div)
          w1.width(10, :pt)
          w2.width(20, :pt)
          # w1.preferred_width(nil).should == 10
          # w2.preferred_width(nil).should == 20
          # w3.has_width?.should be(nil)
          grid = @lm.grid(@div)
          @lm.preferred_width(grid, nil).should be(nil)
        end
      end

      context "preferred_height" do
        it "should return zero if the container is empty" do
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should == 0
        end

        it "should return the sum of widget heights + vertical padding" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w1.height(10, :pt)
          w2.height(20, :pt)
          w1.preferred_height(nil).should == 10
          w2.preferred_height(nil).should == 20
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should == 35
        end

        it "should return nil if the height of any widget is unspecified" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w3 = Widgets::Widget.new(@div)
          w1.height(10, :pt)
          w2.height(20, :pt)
          w1.preferred_height(nil).should == 10
          w2.preferred_height(nil).should == 20
          w3.has_height?.should be(nil)
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should be(nil)
        end
      end

      context "russian dolls" do
        it "should nest containers inside each other" do
          div1 = Widgets::Container.new(@page, :layout => 'vbox', :units => :pt, :padding => 5)
          div2 = Widgets::Container.new(div1, :layout => 'vbox', :units => :pt, :padding => 5)
          div3 = Widgets::Container.new(div2, :layout => 'vbox', :units => :pt, :padding => 5)
          div4 = Widgets::Container.new(div3, :layout => 'vbox', :units => :pt, :padding => 5)
          div5 = Widgets::Container.new(div4, :layout => 'vbox', :units => :pt, :padding => 5)
          w1 = Widgets::Widget.new(div5, :units => :pt, :width => 7, :height => 5)

          w1.preferred_width(nil).should == 7
          w1.preferred_height(nil).should == 5
          div5.preferred_width(nil).should == 17
          div5.preferred_height(nil).should == 15
          div4.preferred_width(nil).should == 27
          div4.preferred_height(nil).should == 25
          div3.preferred_width(nil).should == 37
          div3.preferred_height(nil).should == 35
          div2.preferred_width(nil).should == 47
          div2.preferred_height(nil).should == 45
          div1.preferred_width(nil).should == 57
          div1.preferred_height(nil).should == 55
        end
      end
    end
  end
end
