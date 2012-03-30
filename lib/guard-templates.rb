require "guard"
require "guard/guard"
require 'guard/compilers'

module Guard
  class Templates < Guard

    DEFAULTS = { 
      :namespace => 'this'
    }

    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      @watchers = watchers
      @options = DEFAULTS.clone.merge(options)
      @single_file_mode = @options[:output].match(/\.js$/)
      super(watchers, @options)
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_change(paths)
      templates = {}
      paths.each do |path|
        @watchers.each do |watcher|
          if target = get_target(path, watcher)
            type = File.extname(path).gsub(/^\./,'')
            contents = File.read(path)
            if @single_file_mode
              templates[target[:name]] = contents
            else
              File.open(target[:path], 'w') do |f|
                f.write("#{@options[:namespace]}['#{target[:name]}'] = #{compile(contents, type)}") 
              end
            end
          end
        end
      end
      if @single_file_mode
        File.open(@options[:output], 'w') do |f|
          js = templates.map{|k,v| "#{k.dump}: #{v.dump}"}.join(",\n")
          f.write "#{@options[:namespace]}.templates = {#{js}}"
        end
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_deletion(paths)
      for_deletion = []
      paths.each do |path|
        @watchers.each do |watcher|
          if target = get_target(path, watcher) 
            if @single_file_mode 
              for_deletion.push target[:name]
            else
              FileUtils.rm target[:path]
            end
          end
        end
      end
      #for_deletion.map {|p| FileUtils.rm p } if @single_file_mode
    end

    private
    def get_target(path, watcher)
      if match = path.match(watcher.pattern)
        subpath = match[1]
        {:name => subpath, 
         :path => File.join(@options[:output], "#{subpath}.js")} 
      end
    end

    def compile(str, type)
      if Compilers.methods.include?("compile_#{type}")
        Compilers.send("compile_#{type}", str)
      else
        str.dump
      end
    end
    
  end
end
