require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe FlowLayout do

      before :each do
        @style = Styles::LayoutStyle.new(nil)
        @lm = LayoutManager.for_name('flow').new(@style)
      end

      context "initialize" do
        it "should make an FlowLayout instance" do
          @lm.should be_kind_of(FlowLayout)
        end
      end

    end
  end
end
