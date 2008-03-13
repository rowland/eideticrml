$: << File.dirname(__FILE__) + '/../'

require 'erml'

doc = EideticRML::Builder.new do
  styles do
    layout :id => 'table', :padding => "0.5in"
  end
  rules do
    rule 'rect', :width => 2.5, :height => 1.5, :border => 'Black'
    rule 'rect.green', :fill => 'MediumSeaGreen'
    rule 'rect.gold', :fill => 'Gold'
    rule '.relative', :position => 'relative', :width => '100%', :height => '100%'
    rule 'circle', :border => 'Black', :width => 1
    rule 'circle.red', :fill => 'Crimson'
    rule 'circle.gold', :fill => 'Gold'
  end
  pages do
    page :units => 'in', :layout => 'absolute' do
      label :underline => true, :left => 1, :top => 1, :text => "Preformatted Text"
      rect :class => 'green', :left => 1, :top => 1.5
      rect :class => 'gold', :left => 1, :top => 1.5, :shift => [0.25, 0.25], :z_index => -1
      div :left => 1, :top => 4, :width => 5, :height => 5 do
        table :cols => 3, :class => 'relative' do
          9.times { circle :class => 'red' }
        end
        table :cols => 3, :class => 'relative', :shift => [0.1, 0.1], :z_index => -1 do
          9.times { circle :class => 'gold' }
        end
      end
    end
  end
end

pathname = "#{File.basename($0, '.rb')}.pdf"
doc.print(:file => pathname)
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
