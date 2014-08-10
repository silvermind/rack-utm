# encoding: utf-8
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rack-utm"
  gem.homepage = "http://github.com/silvermind/rack-utm"
  gem.license = "MIT"
  gem.summary = %Q{Tracks parameters came via utm links.}
  gem.description = %Q{If the user clicked through from an affiliated site, this middleware will track affiliate tag, referring url and time.} 
  gem.email = "novolab@novotec.ch"
  gem.authors = ["Severin Ulrich"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:spec) do |test|
  test.libs << 'lib' << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

task :default => :spec
