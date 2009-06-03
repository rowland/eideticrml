require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe TableLayout do

      before :each do
        @style = Styles::LayoutStyle.new(nil)
        @lm = LayoutManager.for_name('table').new(@style)
      end

      context "initialize" do
        it "should make an TableLayout instance" do
          @lm.should be_kind_of(TableLayout)
        end
      end

    end
  end
end
