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
      @content = "p.shouty\n  strong HOWDY, \"pardner\"!"
      @template = 'javascripts/templates/home.jade'
      File.open(@template, 'w') {|f| f.write(@content)}
    end

    it "should create a new file with the stringifed template" do
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.jade/)],
                                              :output => 'public/templates')
      @guard_templates.run_on_change [@template]
      File.exists?('public/templates/home.js').should == true
      File.read('public/templates/home.js').should == "this['home'] = #{@content.dump};"
    end

    it "should write the template with a namespace" do
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.jade/)],
                                              :output => 'public/templates',
                                              :namespace => 'App.Jawesome'
                                             )
      @guard_templates.run_on_change [@template]
      File.read('public/templates/home.js').should == "App.Jawesome['home'] = #{@content.dump};"
    end
  end
end
