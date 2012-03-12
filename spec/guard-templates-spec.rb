require "rubygems"
require "bundler/setup"
require 'fakefs/safe'
require 'execjs'

require 'guard-templates'
require 'guard/watcher'

# ExecJS needs real filesystem access to find the js engine
def eval_js(str)
  FakeFS.deactivate!
  result = ExecJS.eval "(#{str})"
  FakeFS.activate!
  result
end


describe Guard::Templates do 
  before(:each) do
    FakeFS.activate!
    FileUtils.mkdir_p 'javascripts/templates'
    FileUtils.mkdir_p 'public/templates'
  end

  after(:each) do
    FileUtils.rm_rf 'javascripts'
    FileUtils.rm_rf 'public'
    FakeFS.deactivate!
  end

  describe "#run_on_change" do
    before(:each) do
      @content = "p.shouty\n  strong HOWDY, \"pardner\"!"
      @template = 'javascripts/templates/home.jade'
      File.open(@template, 'w') {|f| f.write(@content)}
    end

    it "should create a new file with the stringifed template" do
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.jade/)],
                                              :output => 'public/templates')
      @guard_templates.run_on_change [@template]
      File.exists?('public/templates/home.js').should == true
      File.read('public/templates/home.js').should == "this['home'] = #{@content.dump}"
    end

    it "should write the template with a namespace" do
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.jade/)],
                                              :output => 'public/templates',
                                              :namespace => 'App.Jawesome')
      @guard_templates.run_on_change [@template]
      File.read('public/templates/home.js').should == "App.Jawesome['home'] = #{@content.dump}"
    end

    it "should write the templates to a single file when output has a .js extension" do
      wombat_template = 'javascripts/templates/wombat.jade'
      wombat_content = 'span.wombat WOMBAT'
      File.open(wombat_template, 'w') {|f| f.write(wombat_content)}
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.jade/)],
                                              :output => 'public/templates/templates.js')
      @guard_templates.run_on_change [@template, wombat_template]
      File.exists?('public/templates/home.js').should == false
      File.exists?('public/templates/wombat.js').should == false
      File.exists?('public/templates/templates.js').should == true
      templates = eval_js File.read('public/templates/templates.js')
      templates.keys.should =~ ['home', 'wombat']
      templates['wombat'].should == wombat_content 
      templates['home'].should == @content
    end
  end

  describe "#run_on_deletion" do
    it "should delete output files with source files are deleted" do
    end
  end

  describe '#run_all' do 
    it "should compile everything" do
    end
  end
end
