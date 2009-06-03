require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe HBoxLayout do

      before :each do
        @style = Styles::LayoutStyle.new(nil)
        @lm = LayoutManager.for_name('hbox').new(@style)
      end

      context "initialize" do
        it "should make an HBoxLayout instance" do
          @lm.should be_kind_of(HBoxLayout)
        end
      end

    end
  end
end
