require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Styles
    describe ParagraphStyle do
      before :each do
        @styles = StyleCollection.new
        @bullet_style = @styles.add('bullet', :id => '*')
        @paragraph_style = @styles.add('para', :id => 'p')
      end

      context "initialize" do
        it "should make a ParagraphStyle" do
          @paragraph_style.should be_kind_of(ParagraphStyle)
        end
      end

      context "color" do
        it "should default to 0 (black)" do
          @paragraph_style.color.should == 0
        end

        it "should accept a named color" do
          @paragraph_style.color 'Red'
          @paragraph_style.color.should == 'Red'
        end
      end

      context "align" do
        it "should default to :left" do
          @paragraph_style.text_align.should == :left
        end

        it "should accept each of :left, :center, :right and :justify symbols" do
          [:left, :center, :right, :justify].each do |align|
            @paragraph_style.text_align align
            @paragraph_style.text_align.should == align
          end
        end

        it "should accept left, center right and justify specifed as strings and convert to symbol form" do
          ['left', 'center', 'right', 'justify'].each do |align|
            @paragraph_style.text_align align
            @paragraph_style.text_align.should == align.to_sym
          end
        end

        it "should ignore bogus values" do
          @paragraph_style.text_align 'bogus'
          @paragraph_style.text_align.should == :left
        end
      end

      context "bullet" do
        it "should default to nil" do
          @paragraph_style.bullet.should be(nil)
        end

        it "should accept and lookup a style id" do
          @paragraph_style.bullet '*'
          @paragraph_style.bullet.should == @bullet_style
        end
      end
    end
  end
end
