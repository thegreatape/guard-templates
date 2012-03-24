require 'execjs'

module Guard
  class Templates < Guard
    module Compilers
      def self.compile_jade(str)
        jade = File.read(File.join(Pathname.new(__FILE__).dirname.to_s, '../engines/jade.js'))
        ExecJS.compile("window = {}; #{jade}").eval("window.jade.compile(#{str.dump}, {client:true, compileDebug:false}).toString()")
        
      end
    end
  end
end
