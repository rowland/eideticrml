require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rcov/rcovtask'

spec = Gem::Specification.new do |s|
  s.name = "eideticrml"
  s.version = "0.1.9"
  s.date = "2009-2-1"
  s.summary = "Report Markup Language"
  s.requirements = "Ruby 1.8.x, eideticpdf"
  s.require_path = '.'
  # s.autorequire = 'erml'
  s.email = "brent.rowland@eideticsoftware.com"
  s.homepage = "http://www.eideticsoftware.com"
  s.author = "Brent Rowland, Eidetic Software, LLC"
  # s.rubyforge_project = "eideticrml"
  # s.test_file = "test/pdf_tests.rb"
  s.has_rdoc = false
  # s.extra_rdoc_files = ['README']
  # s.rdoc_options << '--title' << 'Eidetic RML' << '--main' << 'README' << '-x' << 'test'
  s.files = FileList["*.rb"] + ['Rakefile'] + FileList["test/test*.rb"] + FileList["samples/test*.erml*"] + ['samples/testimg.jpg']
  s.platform = Gem::Platform::RUBY
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

Rake::TestTask.new do |t|
  # t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Rcov::RcovTask.new do |t|
  # t.libs << "test"
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
  require 'erml'
  Dir["samples/*.erml","samples/*.haml"].each do |erml|
    puts erml
    pdf = render_erml(erml)
    `open -a Preview #{pdf}` if RUBY_PLATFORM =~ /darwin/ and ($0 !~ /rake_test_loader/ and $0 !~ /rcov/)
  end
  elapsed = Time.now - start
  puts "Elapsed: #{(elapsed * 1000).round} ms"
end
