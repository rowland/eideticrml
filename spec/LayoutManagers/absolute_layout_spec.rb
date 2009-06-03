require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe LayoutManager do

      before :each do
        @style = Styles::LayoutStyle.new(nil)
        @lm = LayoutManager.for_name('absolute').new(@style)
      end

      context "initialize" do
        it "should make an AbsoluteLayout instance" do
          @lm.should be_kind_of(AbsoluteLayout)
        end
      end

    end
  end
end
