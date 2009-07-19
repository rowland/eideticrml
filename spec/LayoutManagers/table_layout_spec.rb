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

        it "should return zero if the container is empty" do
          grid = @lm.grid(@div)
          @lm.preferred_height(grid, nil).should == 0
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
        end

        it "should return zero if the container is empty" do
          grid = @lm.grid(@div)
          @lm.preferred_width(grid, nil).should == 0
        end

        it "should return the sum of widths + horizontal padding" do
          @w1 = Widgets::Widget.new(@div, :width => 10, :height => 10)
          @w2 = Widgets::Widget.new(@div, :width => 15, :height => 12)
          @w3 = Widgets::Widget.new(@div, :width => 10, :height => 25, :rowspan => 2)
          @w4 = Widgets::Widget.new(@div, :width => 25, :height => 10, :colspan => 2)
          grid = @lm.grid(@div)
          # @w1.height.should == 10
          # @w1.preferred_height(nil).should == 10
          @lm.preferred_width(grid, nil).should == 45 # 10 + (5) + 15 + (5) + 10, vs. 25 + (5) + 10 = 40
        end

        it "should return nil when a column width cannot be determined by at least one cell" do
          @w1 = Widgets::Widget.new(@div, :height => 10)
          @w2 = Widgets::Widget.new(@div, :width => 15, :height => 12)
          @w3 = Widgets::Widget.new(@div, :width => 10, :height => 25, :rowspan => 2)
          @w4 = Widgets::Widget.new(@div, :width => 25, :height => 10, :colspan => 2)
          grid = @lm.grid(@div)
          @w1.width.should be(nil)
          @lm.preferred_width(grid, nil).should be(nil)
        end

        # ----------------
        # | w1 | w2 | w3 |
        # |---------|    |
        # | w4      |    |
        # |---------|----|
        # | w5 | w6 | w7 |
        # ----------------
        it "should not return nil when a column width can be determined by at least one cell" do
          @w1 = Widgets::Widget.new(@div, :height => 10)
          @w2 = Widgets::Widget.new(@div, :width => 15, :height => 12)
          @w3 = Widgets::Widget.new(@div, :width => 10, :height => 25, :rowspan => 2)
          @w4 = Widgets::Widget.new(@div, :width => 25, :height => 10, :colspan => 2)
          @w5 = Widgets::Widget.new(@div, :width => 10, :height => 10)
          @w6 = Widgets::Widget.new(@div, :width => 15, :height => 10)
          @w7 = Widgets::Widget.new(@div, :width => 10, :height => 10)
          grid = @lm.grid(@div)
          @lm.preferred_width(grid, nil).should == 45
        end

        it "should correctly measure text" do
          t1 = "Lorem ipsum dolor sit amet,"
          t2 = "consectetur adipisicing elit,"
          t3 = "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
          t4 = "Ut enim ad minim veniam,"
          t5 = "quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
          t6 = "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
          t7 = "Excepteur sint occaecat cupidatat non proident,"
          t8 = "sunt in culpa qui officia deserunt mollit anim id est laborum."
          p1 = Widgets::Paragraph.new(@div, :text => t1, :padding => 3)
          p2 = Widgets::Paragraph.new(@div, :text => t2, :padding => 3)
          p3 = Widgets::Paragraph.new(@div, :text => t3, :padding => 3)
          p4 = Widgets::Paragraph.new(@div, :text => t4, :padding => 3)
          p5 = Widgets::Paragraph.new(@div, :text => t5, :padding => 3)
          p6 = Widgets::Paragraph.new(@div, :text => t6, :padding => 3)
          p7 = Widgets::Paragraph.new(@div, :text => t7, :padding => 3)
          p8 = Widgets::Paragraph.new(@div, :text => t8, :padding => 3, :colspan => 2)
          grid = @lm.grid(@div)
          writer = EideticPDF::DocumentWriter.new
          writer.open
          p1w = p1.preferred_width(writer)
          p2w = p2.preferred_width(writer)
          p3w = p3.preferred_width(writer)
          p4w = p4.preferred_width(writer)
          p5w = p5.preferred_width(writer)
          p6w = p6.preferred_width(writer)
          p7w = p7.preferred_width(writer)
          p8w = p8.preferred_width(writer)
          expected = [p1w, p4w, p7w].max + @style.padding + [p2w, p5w].max + @style.padding + [p3w, p6w].max
          @lm.preferred_width(grid, writer).should == expected
        end
      end
    end
  end
end
