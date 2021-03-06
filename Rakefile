require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = "eideticrml"
  s.version = "0.3.0"
  s.date = "2017-09-11"
  s.summary = "Report Markup Language"
  s.requirements = "Ruby 2.x, eideticpdf"
  s.add_runtime_dependency "eideticpdf", [">= 1.0.2"]
  # s.require_paths = ['lib']
  # s.autorequire = 'lib'
  s.email = "brent.rowland@eideticsoftware.com"
  s.homepage = "http://www.eideticsoftware.com"
  s.author = "Brent Rowland, Eidetic Software, LLC"
  # s.rubyforge_project = "eideticrml"
  # s.test_file = "test/pdf_tests.rb"
  s.has_rdoc = false
  # s.extra_rdoc_files = ['README']
  # s.rdoc_options << '--title' << 'Eidetic RML' << '--main' << 'README' << '-x' << 'test'
  s.files = FileList["lib/*.rb"] + ['Rakefile'] + FileList["test/test*.rb"] + FileList["samples/test*.erml*"] + ['samples/testimg.jpg']
  s.platform = Gem::Platform::RUBY
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc "Clean up files generated by tests."
task :clean do
  rm Dir["*.pdf"]
  rm Dir["samples/*.pdf"]
  rm Dir["test/*.pdf"]
end

desc "Render test erml files to pdf."
task :ermls do
  start = Time.now
  pdfs = []
  require_relative 'lib/erml'
  Dir["samples/*.erml","samples/*.haml","samples/*.erb"].each do |erml|
    puts erml
    pdfs << render_erml(erml)
  end
  elapsed = Time.now - start
  puts "Elapsed: #{(elapsed * 1000).round} ms"
  `open -a Preview #{pdfs * ' '}` if (RUBY_PLATFORM =~ /darwin/) and ($0 !~ /rake_test_loader/)
end
