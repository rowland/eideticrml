require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe FlowLayout do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
        @div = Widgets::Container.new(@page, :layout => 'absolute', :width => '100%', :height => '100%')
        @style = Styles::LayoutStyle.new(nil)
        @lm = LayoutManager.for_name('flow').new(@style)
      end

      context "initialize" do
        it "should make an FlowLayout instance" do
          @lm.should be_kind_of(FlowLayout)
        end
      end

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
    end
  end
end
