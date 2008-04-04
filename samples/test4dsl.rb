$: << File.dirname(__FILE__) + '/../'

require 'erml'

doc = EideticRML::Builder.new do
  pages :units => 'in', :margin => 1 do
    page do
      h "First Page"
    end
    page do
      h "Second Page"
    end
  end
end

pathname = "#{File.basename($0, '.rb')}.pdf"
doc.print(:file => pathname)
`open #{pathname}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
