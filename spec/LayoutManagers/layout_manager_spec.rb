require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe LayoutManager do

      class TestLayout < LayoutManager
      end

      before :each do
        LayoutManager.register('test', TestLayout)
      end

      context "register" do
        it "should register a layout" do
          LayoutManager.class_eval("@@klasses['test']").should == TestLayout
        end
      end

      context "for_name" do
        it "should return the named layout manager" do
          LayoutManager.for_name('test').should == TestLayout
        end
      end

    end
  end
end
