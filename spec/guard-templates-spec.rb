require "rubygems"
require "bundler/setup"
require 'execjs'
require 'fakefs/safe'

require 'guard-templates'
require 'guard/watcher'

# ExecJS needs real filesystem access to find the js engine
def eval_js(str, context='')
  FakeFS.deactivate!
  result = ExecJS.compile(context).eval(str)
  FakeFS.activate!
  result
end

module ExecJS
  class << self
    alias :old_compile :compile
    def compile(source, *args)
      FakeFS.deactivate!
      result = self.old_compile(source, *args)
      FakeFS.activate!
      result
    end
  end
end

ExecJS.runtime.class.const_get('Context').class_eval do
  alias :old_eval :eval
  def eval(source, options={})
    FakeFS.deactivate!
    result = old_eval(source, options)
    FakeFS.activate!
    result
  end
end


describe Guard::Templates do 
  before(:each) do
    # have to write js libs to FakeFS post-fake-activation
    js_src = File.join(Pathname.new(__FILE__).dirname.to_s, '../lib/engines/')
    libs = Dir.glob(File.join(js_src, "*.js")).map do |path|
      [File.basename(path), File.read(path)]
    end
    FakeFS.activate!
    FileUtils.mkdir_p 'lib/engines'
    FileUtils.mkdir_p 'javascripts/templates'
    FileUtils.mkdir_p 'public/templates'
    libs.each do |name, content|
      File.open("lib/engines/#{name}", 'w') {|f| f.write(content)}
    end
  end

  after(:each) do
    FileUtils.rm_rf 'javascripts'
    FileUtils.rm_rf 'public'
    FakeFS.deactivate!
  end

  describe "#run_on_change" do
    before(:each) do
      @content = "<div>\n  {{foo}}\n</div>"
      @template = 'javascripts/templates/home.handlebars'
      File.open(@template, 'w') {|f| f.write(@content)}
    end

    it "should create a new file with the stringifed template" do
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.handlebars/)],
                                              :output => 'public/templates')
      @guard_templates.run_on_change [@template]
      File.exists?('public/templates/home.js').should == true
      File.read('public/templates/home.js').should == "this['home'] = #{@content.dump}"
    end

    it "should write the template with a namespace" do
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.handlebars/)],
                                              :output => 'public/templates',
                                              :namespace => 'App.Jawesome')
      @guard_templates.run_on_change [@template]
      File.read('public/templates/home.js').should == "App.Jawesome['home'] = #{@content.dump}"
    end

    it "should write the templates to a single file when output has a .js extension" do
      wombat_template = 'javascripts/templates/wombat.handlebars'
      wombat_content = '<span>{{wombat}}</span>'
      File.open(wombat_template, 'w') {|f| f.write(wombat_content)}
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.handlebars/)],
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

    it "should compile jade to native functions" do
      jade_template = 'javascripts/templates/jade-test.jade'
      jade_content = '.greetings O HAI'
      File.open(jade_template, 'w') {|f| f.write(jade_content)}
      @guard_templates = Guard::Templates.new([Guard::Watcher.new(/javascripts\/templates\/(.*)\.jade/)],
                                              :namespace => 'app',
                                              :output => 'public/templates')
      @guard_templates.run_on_change [jade_template]
      File.exists?('public/templates/jade-test.js').should == true
      compiled = File.read('public/templates/jade-test.js')
      jade = File.read('lib/engines/jade-runtime.js')
      context = %{var window = {}, app = {};
                  #{jade}
                  #{compiled} }
      fn = "app['jade-test']()"
      eval_js(fn, context).should == '<div class="greetings">O HAI</div>'
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
