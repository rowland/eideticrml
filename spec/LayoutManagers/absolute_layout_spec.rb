require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe AbsoluteLayout do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
        @div = Widgets::Container.new(@page, :layout => 'absolute', :width => '100%', :height => '100%')
        @p = Widgets::Paragraph.new(@div)
        @style = @doc.styles.for_id('absolute')
        @lm = @style.manager
      end

      context "initialize" do
        it "should make an AbsoluteLayout instance" do
          @lm.should be_kind_of(AbsoluteLayout)
          @div.layout.manager.should == @lm
        end
      end

      context "widget position" do
        it "should default to :static" do
          @p.position.should == :static
        end

        it "should be :absolute after layout" do
          @doc.to_s
          @p.position.should == :absolute
        end
      end

      context "widget location" do
        it "should default to (0, 0)" do
          @doc.to_s
          @p.left.should == 0
          @p.top.should == 0
        end

        it "should remain at the absolute coordinates set" do
          @p.left '3'
          @p.top '5'
          @doc.to_s
          @p.left(:in).should == 3
          @p.top(:in).should == 5
        end
      end

      # ----------------
      # | p1 | p2 | p3 |
      # ----------------
      context "grid" do
        it "should place all widgets on one row" do
          p1 = Widgets::Paragraph.new(@div)
          p2 = Widgets::Paragraph.new(@div)
          grid = @lm.grid(@div)
          grid.cols.should == 3
          grid.rows.should == 1
          grid[0, 0].should == @p
          grid[1, 0].should == p1
          grid[2, 0].should == p2
        end
      end

      context "preferred_height" do
        it "should always return nil" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w1.height(10, :pt)
          w2.height(20, :pt)
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should == nil
        end
      end

      context "preferred_width" do
        it "should always return nil" do
          w1 = Widgets::Widget.new(@div)
          w2 = Widgets::Widget.new(@div)
          w1.width(10, :pt)
          w2.width(20, :pt)
          grid = @lm.grid(@div)
          @lm.preferred_width(grid, nil).should == nil
        end
      end
    end
  end
end
