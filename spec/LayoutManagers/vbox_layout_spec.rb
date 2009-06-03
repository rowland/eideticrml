require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe VBoxLayout do

      before :each do
        @style = Styles::LayoutStyle.new(nil)
        @lm = LayoutManager.for_name('vbox').new(@style)
      end

      context "initialize" do
        it "should make an VBoxLayout instance" do
          @lm.should be_kind_of(VBoxLayout)
        end
      end

    end
  end
end
