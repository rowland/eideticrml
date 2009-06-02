require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Support
    describe Grid do
      before :each do
        @grid = Support::Grid.new(3, 2)
      end

      def set6
        @grid[0, 0] = 1
        @grid[1, 0] = 2
        @grid[2, 0] = 3
        @grid[0, 1] = 4
        @grid[1, 1] = 5
        @grid[2, 1] = 6
      end

      def get3
        @grid[0, 0].should == 1
        @grid[1, 0].should == 2
        @grid[2, 0].should == 3
      end

      def get4
        @grid[0, 0].should == 1
        @grid[1, 0].should == 2
        @grid[0, 1].should == 4
        @grid[1, 1].should == 5
      end

      def get6
        get3
        @grid[0, 1].should == 4
        @grid[1, 1].should == 5
        @grid[2, 1].should == 6
      end

      context "index" do
        it "should default to nil" do
          3.times do |c|
            2.times do |r|
              @grid[c,r].should be(nil)
            end
          end
        end

        it "should retrieve the same values that were set" do
          set6
          get6
        end
      end

      context "col" do
        it "should retrieve column values as array" do
          set6
          @grid.col(0).should == [1, 4]
          @grid.col(1).should == [2, 5]
          @grid.col(2).should == [3, 6]
        end
      end

      context "row" do
        it "should retrieve row values as array" do
          set6
          @grid.row(0).should == [1, 2, 3]
          @grid.row(1).should == [4, 5, 6]
        end
      end

      context "rows" do
        it "should resize larger, preserving values at original indices" do
          set6
          @grid.rows = 4
          @grid.rows.should == 4
          get6
        end

        it "should resize smaller, preserving values in remaining rows" do
          set6
          @grid.rows = 1
          @grid.rows.should == 1
          get3
        end
      end

      context "cols" do
        it "should resize larger, preserving values at original indices" do
          set6
          @grid.cols = 5
          @grid.cols.should == 5
          get6
        end

        it "should resize smaller, preserving values in remaining columns" do
          set6
          @grid.cols = 2
          get4
        end
      end
    end
  end
end
