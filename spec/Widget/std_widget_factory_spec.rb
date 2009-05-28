require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe StdWidgetFactory do
      context "initialization" do
        it "should register a namespace" do
          WidgetFactory.for_namespace('std').should == StdWidgetFactory.instance
        end
      end
    end
  end
end
