require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe VBoxLayout do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
        @div = Widgets::Container.new(@page, :layout => 'absolute', :width => '100%', :height => '100%')

        @style = Styles::LayoutStyle.new(nil)
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
    end
  end
end
