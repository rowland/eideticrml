require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe HBoxLayout do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
        @div = Widgets::Container.new(@page, :layout => 'absolute', :width => '100%', :height => '100%')

        @style = Styles::LayoutStyle.new(nil)
        @style.padding(5)
        @lm = LayoutManager.for_name('hbox').new(@style)
      end

      context "initialize" do
        it "should make an HBoxLayout instance" do
          @lm.should be_kind_of(HBoxLayout)
        end
      end

      # -----------
      # | p1 | p2 |
      # -----------
      context "grid" do
        it "should place all widgets on one row" do
          p1 = Widgets::Paragraph.new(@div)
          p2 = Widgets::Paragraph.new(@div)
          grid = @lm.grid(@div)
          grid.cols.should == 2
          grid.rows.should == 1
          grid[0, 0].should == p1
          grid[1, 0].should == p2
        end
      end

      context "preferred_height" do
        it "should return the max widget height" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w1.height(10, :pt)
          w2.height(20, :pt)
          # w1.preferred_height(nil).should == 10
          # w2.preferred_height(nil).should == 20
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should == 20
        end
      end

      context "preferred_width" do
        it "should return the sum of widget widths + horizontal padding" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w1.width(10, :pt)
          w2.width(20, :pt)
          # w1.preferred_width(nil).should == 10
          # w2.preferred_width(nil).should == 20
          grid = @lm.grid(@div)
          @lm.preferred_width(grid, nil).should == 35
        end
      end
    end
  end
end
