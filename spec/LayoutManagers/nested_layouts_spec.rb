require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module LayoutManagers
    describe "Nested Layouts" do

      before :each do
        @doc = Widgets::Document.new(nil, :units => :in)
        @page = Widgets::Page.new(@doc, :margin => 1)
      end

      context "circle-rect-p" do
        w = 60
        h = 50
        r = Math.sqrt(((w) / 2.0) ** 2 + ((h) / 2.0) ** 2)

        before :each do
          @circle = Widgets::Circle.new(@page)
          @rect = Widgets::Rectangle.new(@circle)
          @p = Widgets::Paragraph.new(@rect, :width => "#{w}pt", :height => "#{h}pt", :text => "Paragraph with four words.")
          @writer = EideticPDF::DocumentWriter.new
          @writer.open(:v_text_align => :base, :text_encoding => 'UTF8')
          @doc.to_s
        end

        context "p" do
          context "preferred_width" do
            it "should be #{w}" do
              @p.preferred_width(@writer).should == w
            end
          end

          context "preferred_height" do
            it "should be #{h}" do
              @p.preferred_height(@writer).should == h
            end
          end

          context "width" do
            it "should be #{w}" do
              @p.width.should == w
            end
          end

          context "height" do
            it "should be #{h}" do
              @p.height.should == h
            end
          end

          context "left" do
            it "should be flush with container" do
              @p.left.should == @rect.left
            end
          end

          context "top" do
            it "should be flush with container" do
              @p.top.should == @rect.top
            end
          end
        end

        context "rect" do
          context "preferred_width" do
            it "should be #{w}" do
              @rect.preferred_width(@writer).should == w
            end
          end

          context "preferred_height" do
            it "should be #{h}" do
              @rect.preferred_height(@writer).should == h
            end
          end

          context "width" do
            it "should be #{w}" do
              @rect.width.should == w
            end
          end

          context "height" do
            it "should be #{h}" do
              @rect.height.should == h
            end
          end

          context "left" do
            it "should equal circle.left + (circle.width - rect.width) / 2" do
              @rect.left.should == @circle.left + (@circle.width - @rect.width) / 2.0
            end
          end

          context "top" do
            it "should equal circle.top + (circle.height - rect.height) / 2" do
              @rect.top.should == @circle.top + (@circle.height - @rect.height) / 2.0
            end
          end
        end

        context "circle" do
          it "should have a preferred radius of #{r}" do
            @circle.preferred_radius(@writer).should == r
          end

          it "should have a radius of #{r}" do
            @circle.r.should == r
          end

          it "should be #{r * 2} wide" do
            @circle.width.should == r * 2
          end

          it "should be #{r * 2} high" do
            @circle.height.should == r * 2
          end
        end
      end
    end
  end
end

