require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Paragraph do
      Lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

      before :each do
        @doc = StdWidgetFactory.instance.make_widget('erml', nil)
        @centered = @doc.styles.add('para', :id => 'centered', :text_align => :center)
        @zapf = @doc.styles.add('font', :id => 'zapf', :name => 'ZapfDingbats', :size => 12)
        @bullet = @doc.styles.add('bullet', :id => 'bstar', :font => 'zapf', :text => "&#x4E;")
        @page = StdWidgetFactory.instance.make_widget('page', @doc)
        @p = StdWidgetFactory.instance.make_widget('p', @page)
        @writer = EideticPDF::DocumentWriter.new
        @writer.open
      end

      after :each do
        @writer.close
      end

      context "make_widget" do
        it "should make a Paragraph" do
          @p.should be_instance_of(Paragraph)
        end

        it "should have its parent set to page" do
          @p.parent.should == @page
        end

        it "should have its tag set to p" do
          @p.tag.should == 'p'
        end
      end

      context "bullet" do
        it "should default to nil" do
          @p.bullet.should == nil
        end

        it "should accept a named bullet style" do
          @p.bullet('bstar')
          @p.bullet.should == @bullet
          @p.bullet.width.should == 36
          @p.bullet.width(:in).should == 0.5
        end
      end

      def assert_paragraph_defaults(ps)
        ps.text_align.should == :left
        ps.bullet.should == nil
      end

      context "style" do
        it "should default to left-aligned with no bullet" do
          assert_paragraph_defaults(@doc.paragraph_style)
          assert_paragraph_defaults(@p.style)
          @p.text_align.should == :left
        end

        it "should accept a named para style without changing document defaults" do
          @p.style('centered')
          @p.style.should == @centered
          @p.text_align.should == :center
          assert_paragraph_defaults(@doc.paragraph_style)
        end
        
        it "should support copying to allow updates without change document style" do
          @p.style(:copy).text_align('right')
          @p.style.should_not == @centered
          @p.text_align.should == :right
          assert_paragraph_defaults(@doc.paragraph_style)
        end
      end

      context "preferred_width" do
        it "should calculate a preferred width, given a piece of text" do
          @page.margin("1in")
          @p.text(Lorem)
          pw = @p.preferred_width(@writer, :in)
          pw.should <= 6.5
          pw.should >= 6.0
        end
      end

      context "preferred_height" do # small
        it "should calculcate preferred height for a small piece of text" do
          @p.text("Hello")
          ph = @p.preferred_height(@writer)
          ph.should be_close(12, 1)
        end
        
        it "should calculate preferred height for a large piece of text" do
          @page.margin("1in")
          @p.text(Lorem)
          ph = @p.preferred_height(@writer)
          ph.should be_close(105.45, 1)
        end
      end

      context "strikeout" do
        it "should default to nil (false)" do
          @p.strikeout.should == nil
        end

        it "should accept a true value" do
          @p.strikeout(true)
          @p.strikeout.should be(true)
        end

        it "should accept a false value" do
          @p.strikeout(true)
          @p.strikeout(false)
          @p.strikeout.should be(false)
        end

        it "should accept a true string value" do
          @p.strikeout("true")
          @p.strikeout.should be(true)
        end

        it "should accept a false string value" do
          @p.strikeout("true")
          @p.strikeout("false")
          @p.strikeout.should be(false)
        end
      end

      context "text" do
        it "should default to nil" do
          @p.text.should == nil
        end

        it "should accept a string value and return a sequence of text pieces" do
          @p.text("text")
          @p.text.first.should == ["text", @p.font]
        end

        it "should replace newlines and any following whitespace with a single space" do
          @p.text("first\n\t second")
          @p.text.first.should == ["first second", @p.font]
        end

        it "should allow non-string values (like spans)" do
          pageno = StdWidgetFactory.instance.make_widget('pageno', @p)
        end
      end

      context "underline" do
        it "should default to nil (false)" do
          @p.underline.should == nil
        end

        it "should accept a true value" do
          @p.underline(true)
          @p.underline.should be(true)
        end

        it "should accept a false value" do
          @p.underline(false)
          @p.underline.should be(false)
        end

        it "should accept a true string value" do
          @p.underline("true")
          @p.underline.should be(true)
        end

        it "should accept a false string value" do
          @p.underline("false")
          @p.underline.should be(false)
        end
      end

      context "has_height?" do
        it "should always be true" do
          @p.has_height?.should be(true)
        end
      end

      context "has_width?" do
        it "should always be true" do
          @p.has_width?.should be(true)
        end
      end
    end
  end
end
