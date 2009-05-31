require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Label do
      before :each do
        @doc = StdWidgetFactory.instance.make_widget('erml', nil)
        @label = StdWidgetFactory.instance.make_widget('label', @doc)
      end

      context "make_widget" do
        it "should make a label" do
          @label.should_not == nil
          @label.should be_instance_of(Label)
        end
      end

      context "angle" do
        it "should default to zero" do
          @label.angle.should == 0
        end

        it "should accept a numeric value" do
          @label.angle(90)
          @label.angle.should == 90
        end
      end

      context "text" do
        it "should default to an empty string" do
          @label.text.should == ''
        end

        it "should accept a string value" do
          @label.text("text")
          @label.text.should == "text"
        end
      end
    end
  end
end
