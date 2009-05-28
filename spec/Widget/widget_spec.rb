require File.dirname(__FILE__) + '/../spec_helper'

module EideticRML
  module Widgets
    describe Widget do
      before :each do
        @doc = StdWidgetFactory.instance.make_widget('erml', nil)
        @alt = @doc.styles.add('font', :id => 'alt', :name => 'Times', :size => 10, :style => 'Bold', :encoding => 'CP1252', :color => '0xFFFFFF')
        @blue_dash = @doc.styles.add('pen', :id => 'blue_dash', :color => 'Blue', :width => '4pt', :pattern => 'dashed')
        @dotted = @doc.styles.for_id('dotted')
        @battleship = @doc.styles.add('brush', :id => 'battleship', :color => 'LightSteelBlue')
        @page = StdWidgetFactory.instance.make_widget('page', @doc)
        @widget = Widget.new(@page)
      end

      context "setup" do
        it "should create some widgets" do
          @widget.should_not == nil
          @page.should_not == nil
          @doc.should_not == nil
        end
      end

      context "@page" do
        it "should be @widget.parent" do
          @page.should == @widget.parent
        end
      end

      context "align" do
        it "should default to nil" do
          @widget.align.should == nil
        end

        it "should allow assignment of legitimate values" do
          [:top, :right, :bottom, :left].each do |align|
            @widget.align(align)
            @widget.align.should == align
          end
        end

        it "should remain unchanged when a bogus value is assigned" do
          @widget.align(:left)
          @widget.align(:bogus)
          @widget.align.should == :left
        end
      end

      context "position" do
        it "should default to :static" do
          @widget.position.should == :static
        end

        it "should allow assignment of :relative, :absolute and :static symbols" do
          @widget.position(:relative)
          @widget.position.should == :relative
          @widget.position(:absolute)
          @widget.position.should == :absolute
          @widget.position(:static)
          @widget.position.should == :static
        end

        it "should allow assignment of 'static', 'relative' and 'absolute' and convert them to symbols" do
          @widget.position("relative")
          @widget.position.should == :relative
          @widget.position("absolute")
          @widget.position.should == :absolute
          @widget.position("static")
          @widget.position.should == :static
        end

        it "should ignore assignment of bogus values" do
          @widget.position(:bogus)
          @widget.position.should == :static
          @widget.position("bogus")
          @widget.position.should == :static
        end

        it "should change from static to relative when top is set with string value" do
          @widget.top "7"
          @widget.position.should == :relative
        end

        it "should change from static to relative when right is set with string" do
          @widget.right "7"
          @widget.position.should == :relative
        end

        it "should change from static to relative when bottom is set with string value" do
          @widget.bottom "7"
          @widget.position.should == :relative
        end

        it "should change from static to relative when left is set with string value" do
          @widget.left "7"
          @widget.position.should == :relative
        end
      end

      context "tag" do
        it "should default to nil" do
          @widget.tag.should == nil
        end

        it "should ignore bogus values" do
          @widget.tag(' !@#$%')
          @widget.tag.should == nil
        end

        it "should allow valid values" do
          @widget.tag('widget')
          @widget.tag.should == 'widget'
        end
      end
      
      context "id" do
        it "should default to nil" do
          @widget.id.should == nil
        end
        
        it "should ignore bogus values" do
          @widget.id(' !@#$%')
          @widget.id.should == nil
        end
        
        it "should allow valid values" do
          @widget.id('widget')
          @widget.id.should == 'widget'
        end
      end

      context "klass" do
        it "should default to nil" do
          @widget.klass.should == nil
        end
        
        it "should ignore bogus values" do
          @widget.klass(' !@#$%')
          @widget.klass.should == nil
        end
        
        it "should allow valid values" do
          @widget.klass('foo bar')
          @widget.klass.should == 'foo bar'
        end
      end

      context "selector_tag" do
        it "should have expected values for @doc and @page" do
          @doc.selector_tag.should == 'erml'
          @page.selector_tag.should == 'page'
        end
        
        it "should start with a default value and change as id and class are assigned" do
          p1 = StdWidgetFactory.instance.make_widget('p', @page)
          p1.selector_tag.should == 'p'
          p1.id('id')
          p1.selector_tag.should == 'p#id'
          p1.klass('class')
          p1.selector_tag.should == 'p#id.class'

          p2 = StdWidgetFactory.instance.make_widget('p', @page)
          p2.klass('class')
          p2.selector_tag.should == 'p.class'
        end
      end
      
      context "path" do
        it "should have expected values for @doc and @page" do
          @doc.path.should == 'erml'
          @page.path.should == 'erml/page'
        end
        
        it "should start with a default value and change as id and class are assigned" do
          p1 = StdWidgetFactory.instance.make_widget('p', @page)
          p1.path.should == 'erml/page/p'
          p1.id('id')
          p1.path.should == 'erml/page/p#id'
          p1.klass('class')
          p1.path.should == 'erml/page/p#id.class'

          p2 = StdWidgetFactory.instance.make_widget('p', @page)
          p2.klass('class')
          p2.path.should == 'erml/page/p.class'
        end
      end
      
      context "top" do
        it "should be settable with default units" do
          @widget.top("18")
          @widget.top.should == 18
          @widget.top(:in).should == 0.25
        end

        it "should be added to height to determine bottom" do
          @widget.top("0.25in")
          @widget.height("7in")
          @widget.bottom(:in).should == 7.25
        end

        it "should treat negative values as relative to container bottom" do
          @widget.top("-2in")
          @widget.top(:in).should == 9
        end
      end

      context "right" do
        it "should be settable with default units" do
          @widget.right("36")
          @widget.right.should == 36
          @widget.right(:in).should == 0.5
        end
        
        it "should allow width to be subtracted to determine left" do
          @widget.right(342)
          @widget.right(:in).should == 4.75
          @widget.width(1, :in)
          @widget.left(:in).should == 3.75
        end
        
        it "should treat negative values as relative to container right" do
          @widget.right("-1in")
          @widget.width(1, :in)
          @widget.left(:in).should == 6.5
        end
      end

      context "bottom" do
        it "should be settable with default units" do
          @widget.bottom("54")
          @widget.bottom.should == 54
          @widget.bottom(:in).should == 0.75
        end
        
        it "should allow height to be subtracted to determine top" do
          @widget.bottom(54)
          @widget.height(36)
          @widget.top.should == 18
        end
      
        it "should treat negative values as relative to container bottom" do
          @widget.bottom("-144")
          @widget.height("72")
          @widget.top.should == 576
          @widget.top(:in).should == 8
        end
      end

      context "left" do
        it "should be settable with default units" do
          @widget.left("72")
          @widget.left.should == 72
          @widget.left(:in).should == 1
        end

        it "should be added to width to determine right" do
          @widget.left("1in")
          @widget.width("7in")
          @widget.right(:in).should == 8
        end

        it "should treat negative values as relative to container width" do
          @widget.left("-2in")
          @widget.left(:in).should == 6.5
        end
      end

      context "widget in div" do
        before :each do
          @div = StdWidgetFactory.instance.make_widget('div', @page)
          @div.position(:absolute)
          @div.top "1in"
          @div.left "1in"
          @div.width "2in"
          @div.height "2in"
        end

        context "top" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.top("0.5in")
            w.top.should == 108
            w.top(:in).should == 1.5
          end
        end

        context "right" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.right("-0.5in")
            w.right.should == 180
            w.right(:in).should == 2.5
          end
        end

        context "bottom" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.bottom("-0.5in")
            w.bottom.should == 180
            w.bottom(:in).should == 2.5
          end
        end

        context "left" do
          it "should allow positioning relative to container" do
            w = Widget.new(@div)
            w.left("0.5in")
            w.left.should == 108
            w.left(:in).should == 1.5
          end
        end
      end

      context "units" do
        it "should default to :pt" do
          @doc.units.should == :pt
          @widget.units.should == :pt
        end

        it "should should be inherited from container" do
          @doc.units(:in)
          @doc.units.should == :in
          @widget.units.should == :in
        end

        it "should allow inherited value to be overridden" do
          @widget.units(:in)
          @widget.units.should == :in
          @doc.units.should == :pt
        end
      end
      
      def assert_font_defaults(f)
        f.should_not == nil
        f.name.should == 'Helvetica'
        f.size.should == 12
        f.style.should == ''
        f.sub_type.should == 'Type1'
        f.encoding.should == 'WinAnsiEncoding'
        f.color.should == 0
      end
      
      context "font" do
        it "should have expected defaults" do
          assert_font_defaults(@doc.font)
          @widget.font.should == @doc.font
        end

        it "should be overridable" do
          @widget.font('alt')
          @widget.font.should == @alt
          assert_font_defaults(@doc.font) # unchanged
        end

        it "should be copyable" do
          @widget.font(:copy)
          @widget.font.should_not == @doc.font
        end

        it "should not affect parent when copied" do
          @widget.font(:copy).size(20)
          @widget.font.size.should == 20
          assert_font_defaults(@doc.font) # unchanged
        end

        it "should allow style to be set without affecting parent" do
          @widget.font_style('Italic')
          @widget.font.style.should == 'Italic'
          assert_font_defaults(@doc.font) # unchanged
        end

        it "should allow color to be set without affecting parent" do
          @widget.font_color('Orange')
          @widget.font.color.should == 'Orange'
          assert_font_defaults(@doc.font) # unchanged
        end

        it "should allow size to be set without affecting parent" do
          @widget.font_size(13)
          @widget.font.size.should == 13
          assert_font_defaults(@doc.font) # unchanged
        end

        it "should allow weight to be set without affecting parent" do
          @widget.font_weight('Bold')
          @widget.font_weight.should == 'Bold'
          assert_font_defaults(@doc.font) # unchanged
        end
      end

      context "width" do
        it "should default to nil" do
          @widget.width.should == nil
        end

        it "should accept a fixed value in the default units" do
          @page.units(:in)
          @widget.width('5')
          @widget.width(:in).should == 5
          @widget.width.should == 360
        end

        it "should accept a percentage of page width" do
          @widget.width('50%')
          @widget.width_pct.should == 0.5
          @widget.width(:in).should == 4.25
          @widget.width.should == 306
        end

        it "should accept a percentage of a parent widget's width" do
          @widget.width('50%')
          w = Widget.new(@widget)
          w.width('50%')
          w.width_pct.should == 0.5
          w.width(:in).should == 2.125
          w.width.should == 153
        end

        it "should resize along with parent when a percent is specified" do
          @widget.width('50%')
          w = Widget.new(@widget)
          w.width('50%')
          @widget.width('100%')
          w.width_pct.should == 0.5
          w.width(:in).should == 4.25
          w.width.should == 306
        end
        
        it "should accept negative relative values" do
          @page.margin('1in')
          @widget.width('-2in')
          @widget.width(:in).should == 4.5
          @widget.width.should == 324
        end
        
        it "should accept positive relative values" do
          @page.margin('1in')
          @widget.width('+1in')
          @widget.width(:in).should == 7.5
          @widget.width.should == 540
        end
      end

      context "height" do
        it "should default to nil" do
          @widget.height.should == nil
        end

        it "should accept a fixed value in the default units" do
          @page.units(:in)
          @widget.height('3.5')
          @widget.height(:in).should == 3.5
          @widget.height.should == 252
        end

        it "should accept a percentage of page height" do
          @widget.height('50%')
          @widget.height_pct.should == 0.5
          @widget.height(:in).should == 5.5
          @widget.height.should == 396
        end

        it "should accept a percentage of a parent widget's height" do
          @widget.height('50%')
          w = Widget.new(@widget)
          w.height('50%')
          w.height_pct.should == 0.5
          w.height(:in).should == 2.75
          w.height.should == 198
        end

        it "should resize along with parent when a percent is specified" do
          @widget.height('50%')
          w = Widget.new(@widget)
          w.height('50%')
          @widget.height('100%')
          w.height_pct.should == 0.5
          w.height(:in).should == 5.5
          w.height.should == 396
        end

        it "should accept negative relative values" do
          @page.margin('1in')
          @widget.height('-2in')
          @widget.height(:in).should == 7
          @widget.height.should == 504
        end

        it "should accept positive relative values" do
          @page.margin('1in')
          @widget.height('+1in')
          @widget.height(:in).should == 10
          @widget.height.should == 720
        end
      end

      context "max_width" do
        it "should default to nil" do
          @widget.max_width.should == nil
        end

        it "should accept a fixed value in the default units" do
          @page.units(:in)
          @widget.max_width('5')
          @widget.max_width(:in).should == 5
          @widget.max_width.should == 360
        end

        it "should accept a percentage of page width" do
          @page.units(:in)
          @widget.max_width('50%')
          @widget.max_width_pct.should == 0.5
          @widget.max_width(:in).should == 4.25
          @widget.max_width.should == 306
        end

        it "should accept a percentage of a parent widget's width" do
          @widget.width('50%')
          w = Widget.new(@widget)
          w.max_width('50%')
          w.max_width_pct.should == 0.5
          w.max_width(:in).should == 2.125
          w.max_width.should == 153
        end

        it "should resize along with parent when a percent is specified" do
          @widget.width('50%')
          w = Widget.new(@widget)
          w.max_width('50%')
          @widget.width('100%')
          w.max_width_pct.should == 0.5
          w.max_width(:in).should == 4.25
          w.max_width.should == 306
        end

        it "should accept negative relative values" do
          @page.margin('1in')
          @widget.max_width('-2in')
          @widget.max_width(:in).should == 4.5
          @widget.max_width.should == 324
        end

        it "should accept positive relative values" do
          @page.margin('1in')
          @widget.max_width('+1in')
          @widget.max_width(:in).should == 7.5
          @widget.max_width.should == 540
        end
      end

      context "max_height" do
        it "should default to nil" do
          @widget.max_height.should == nil
        end

        it "should accept a fixed value in the default units" do
          @page.units(:in)
          @widget.max_height('3.5')
          @widget.max_height(:in).should == 3.5
          @widget.max_height.should == 252
        end

        it "should accept a percentage of page height" do
          @page.units(:in)
          @widget.max_height('50%')
          @widget.max_height_pct.should == 0.5
          @widget.max_height(:in).should == 5.5
          @widget.max_height.should == 396
        end

        it "should accept a percentage of a parent widget's height" do
          @widget.height('50%')
          w = Widget.new(@widget)
          w.max_height('50%')
          w.max_height_pct.should == 0.5
          w.max_height(:in).should == 2.75
          w.max_height.should == 198
        end

        it "should resize along with parent when a percent is specified" do
          @widget.height('50%')
          w = Widget.new(@widget)
          w.max_height('50%')
          @widget.height('100%')
          w.max_height_pct.should == 0.5
          w.max_height(:in).should == 5.5
          w.max_height.should == 396
        end

        it "should accept negative relative values" do
          @page.margin('1in')
          @widget.max_height('-2in')
          @widget.max_height(:in).should == 7
          @widget.max_height.should == 504
        end

        it "should accept positive relative values" do
          @page.margin('1in')
          @widget.max_height('+1in')
          @widget.max_height(:in).should == 10
          @widget.max_height.should == 720
        end
      end
      
      context "content_top" do
        before :each do
          @widget.top(50)
        end
        
        it "should default to the widget top" do
          @widget.content_top.should == 50
        end
        
        it "should be increased by padding" do
          @widget.padding(10)
          @widget.content_top.should == 60
        end
        
        it "should be increased by margin" do
          @widget.margin(5)
          @widget.content_top.should == 55
        end
        
        it "should be increased by the sum of padding and margin" do
          @widget.padding(10)
          @widget.margin(5)
          @widget.content_top.should == 65
        end
      end

      context "content_right" do
        before :each do
          @widget.right(50)
        end

        it "should default to the widget right" do
          @widget.content_right.should == 50
        end

        it "should be reduced by padding" do
          @widget.padding(10)
          @widget.content_right.should == 40
        end

        it "should be reduced by margin" do
          @widget.margin(5)
          @widget.content_right.should == 45
        end

        it "should be reduced by the sum of padding and margin" do
          @widget.padding(10)
          @widget.margin(5)
          @widget.content_right.should == 35
        end
      end

      context "content_bottom" do
        before :each do
          @widget.bottom(50)
        end

        it "should default to the widget bottom" do
          @widget.content_bottom.should == 50
        end

        it "should be reduced by padding" do
          @widget.padding(10)
          @widget.content_bottom.should == 40
        end

        it "should be reduced by margin" do
          @widget.margin(5)
          @widget.content_bottom.should == 45
        end

        it "should be reduced by the sum of padding and margin" do
          @widget.padding(10)
          @widget.margin(5)
          @widget.content_bottom.should == 35
        end
      end

      context "content_left" do
        before :each do
          @widget.left(50)
        end

        it "should default to the widget left" do
          @widget.content_left.should == 50
        end

        it "should be increased by padding" do
          @widget.padding(10)
          @widget.content_left.should == 60
        end

        it "should be increased by margin" do
          @widget.margin(5)
          @widget.content_left.should == 55
        end

        it "should be increased by the sum of padding and margin" do
          @widget.padding(10)
          @widget.margin(5)
          @widget.content_left.should == 65
        end
      end

      context "content_width" do
        it "should default to zero" do
          @widget.content_width.should == 0
        end
        
        it "should equal width without margins or padding" do
          @widget.width('36')
          @widget.content_width.should == 36
          @widget.content_width(:in).should == 0.5
        end
        
        it "should be reduced by margin" do
          @widget.width('36')
          @widget.margin([1,2,3,4]) # right=2, left=4
          @widget.content_width.should == 30
        end
        
        it "should be reduced by padding" do
          @widget.width('36')
          @widget.padding([4,3,2,1]) # right=3, left=1
          @widget.content_width.should == 32
        end
        
        it "should be reduced by the sum of margin and padding" do
          @widget.width('36')
          @widget.margin([1,2,3,4])
          @widget.padding([4,3,2,1])
          @widget.content_width.should == 26
        end
      end

      context "content_height" do
        it "should default to zero" do
          @widget.content_height.should == 0
        end
        
        it "should equal height without margins or padding" do
          @widget.height('3.5in')
          @widget.content_height.should == 252
          @widget.content_height(:in).should == 3.5
        end

        it "should be reduced by margin" do
          @widget.height('3.5in')
          @widget.margin([1,2,3,4]) # top=1, bottom=3
          @widget.content_height.should == 248
        end
        
        it "should be reduced by padding" do
          @widget.height('3.5in')
          @widget.padding([4,3,2,1]) # top=4, bottom=2
          @widget.content_height.should == 246
        end
        
        it "should be reduced by the sum of margin and padding" do
          @widget.height('3.5in')
          @widget.margin([1,2,3,4])
          @widget.padding([4,3,2,1])
          @widget.content_height.should == 242
        end
      end
    end
  end
end
