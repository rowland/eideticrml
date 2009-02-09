$: << File.dirname(__FILE__) + '/../'

require 'erml'

doc = EideticRML::Builder.new do
  styles do
    pen :id => 'blue_dash', :color => 'Blue', :width => '4pt', :pattern => 'dashed'
  end
  pages do
    page :units => 'in', :margin => 1 do
      rect :width => '100%', :height => 2, :border => 'blue_dash', :corners => 0.5
    end
  end
end

pathname = "#{File.basename($0, '.rb')}.pdf"
doc.print(:file => pathname)
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
