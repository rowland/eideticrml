require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe TableLayout do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
        @div = Widgets::Container.new(@page, :layout => 'absolute', :width => '100%', :height => '100%', :units => :pt)

        @style = Styles::LayoutStyle.new(nil)
        @style.padding(5)
        @lm = LayoutManager.for_name('table').new(@style)
      end

      context "initialize" do
        it "should make an TableLayout instance" do
          @lm.should be_kind_of(TableLayout)
        end
      end

      context "grid" do
        before :each do
          @p1 = Widgets::Paragraph.new(@div)
          @p2 = Widgets::Paragraph.new(@div)
          @p3 = Widgets::Paragraph.new(@div)
          @p4 = Widgets::Paragraph.new(@div)
        end

        # ----------------
        # | p1 | p2 | p3 |
        # |---------|    |
        # | p4      |    |
        # ----------------
        it "should place widgets in rows when order == :rows" do
          @div.cols(3)
          @div.order(:rows)
          @p3.rowspan(2)
          @p4.colspan(2)
          grid = @lm.grid(@div)
          grid.cols.should == 3
          grid.rows.should == 2
          grid[0, 0].should == @p1
          grid[1, 0].should == @p2
          grid[2, 0].should == @p3
          grid[0, 1].should == @p4
          grid[1, 1].should be(false)
          grid[2, 1].should be(false)
        end

        # -----------
        # | p1 | p4 |
        # |----|    |
        # | p2 |    |
        # |----|----|
        # | p3      |
        # -----------
        it "should place widgets in columns when order == :cols" do
          @div.rows(3)
          @div.order(:cols)
          @p3.colspan(2)
          @p4.rowspan(2)
          grid = @lm.grid(@div)
          grid.cols.should == 2
          grid.rows.should == 3
          grid[0, 0].should == @p1
          grid[0, 1].should == @p2
        end
      end

      context "preferred_height" do
        # -----------
        # | w1 | w4 |
        # |----|    |
        # | w2 |    |
        # |----|----|
        # | w3      |
        # -----------
        before :each do
          @div.rows(3)
          @div.order(:cols)
        end

        it "should return the sum of heights + vertical padding" do
          @w1 = Widgets::Widget.new(@div, :width => 10, :height => 10)
          @w2 = Widgets::Widget.new(@div, :width => 15, :height => 12)
          @w3 = Widgets::Widget.new(@div, :width => 25, :height => 10, :colspan => 2)
          @w4 = Widgets::Widget.new(@div, :width => 10, :height => 25, :rowspan => 2)
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should == 42 # 10 + (5) + 12 + (5) + 10, vs. 25 + (5) + 10 = 42
        end

        it "should return nil when a row height cannot be determined" do
          @w1 = Widgets::Widget.new(@div, :width => 10)
          @w2 = Widgets::Widget.new(@div, :width => 15, :height => 12)
          @w3 = Widgets::Widget.new(@div, :width => 25, :height => 10, :colspan => 2)
          @w4 = Widgets::Widget.new(@div, :width => 10, :height => 25, :rowspan => 2)
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should be(nil)
        end

        # ----------------
        # | w1 | w4 | w5 |
        # |----|    |----|
        # | w2 |    | w6 |
        # |----|----|----|
        # | w3      | w7 |
        # ----------------
        it "should not return nil when a row height can be determined by at least one cell" do
          @w1 = Widgets::Widget.new(@div, :width => 10)
          @w2 = Widgets::Widget.new(@div, :width => 15, :height => 12)
          @w3 = Widgets::Widget.new(@div, :width => 25, :height => 10, :colspan => 2)
          @w4 = Widgets::Widget.new(@div, :width => 10, :height => 25, :rowspan => 2)
          @w5 = Widgets::Widget.new(@div, :width => 25, :height => 10)
          @w6 = Widgets::Widget.new(@div, :width => 10, :height => 12)
          @w7 = Widgets::Widget.new(@div, :width => 10, :height => 10)
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should == 42
        end
      end

      context "preferred_width" do
        # ----------------
        # | w1 | w2 | w3 |
        # |---------|    |
        # | w4      |    |
        # ----------------
        before :each do
          @div.cols(3)
          @div.order(:rows)
          @w1 = Widgets::Widget.new(@div, :width => 10, :height => 10)
          @w2 = Widgets::Widget.new(@div, :width => 15, :height => 12)
          @w3 = Widgets::Widget.new(@div, :width => 10, :height => 25, :rowspan => 2)
          @w4 = Widgets::Widget.new(@div, :width => 25, :height => 10, :colspan => 2)
        end

        # it "should return the sum of widths + horizontal padding" do
        #   grid = @lm.grid(@div)
        #   @w1.height.should == 10
        #   @w1.preferred_height(nil).should == 10
        #   @lm.preferred_width(grid, nil).should == 45 # 10 + (5) + 15 + (5) + 10, vs. 25 + (5) + 10 = 40
        # end
      end
    end
  end
end
