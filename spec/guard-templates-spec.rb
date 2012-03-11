require "rubygems"
require "bundler/setup"
require 'fakefs'
require 'guard-templates'
require 'guard/watcher'

describe Guard::Templates do 
  before(:all) do
    FileUtils.mkdir_p 'javascripts/templates'
    FileUtils.mkdir_p 'public/templates'
  end

  after(:all) do
    FileUtils.rm_rf 'javascripts'
    FileUtils.rm_rf 'public'
  end

  describe "#run_on_change" do
    before(:all) do
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.jade/)],
                                              :output => 'public/templates')
      template = "h1.shouty HOWDY!"
      File.open('javascripts/templates/home.jade', 'w') {|f| f.write(template)}
    end

    it "should create a new file with the stringifed template" do
      @guard_templates.run_on_change ['javascripts/templates/home.jade']
      File.exists?('public/templates/home.js').should == true
    end
  end
end
