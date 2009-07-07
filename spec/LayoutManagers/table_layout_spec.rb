require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe TableLayout do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
        @div = Widgets::Container.new(@page, :layout => 'absolute', :width => '100%', :height => '100%')

        @style = Styles::LayoutStyle.new(nil)
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
    end
  end
end
