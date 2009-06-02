require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe Style do

      class TestStyle < Style
      end

      before :each do
        @style = Style.new(nil)
      end

      context "id" do
        it "should default to nil" do
          @style.id.should be(nil)
        end

        it "should accept string values" do
          @style.id 'foo'
          @style.id.should == 'foo'
        end

        it "should convert numeric values to strings" do
          @style.id 33
          @style.id.should == '33'
        end
      end

      context "register" do
        it "should register the style" do
          Style.register('test', TestStyle)
          Style.class_eval("@@klasses['test']").should == TestStyle
        end
      end

      context "for_name" do
        it "should return the named style" do
          Style.register('test', TestStyle)
          Style.for_name('test').should == TestStyle
        end
      end
    end
  end
end
