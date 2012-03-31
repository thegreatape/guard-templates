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
      run_all
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
      run_on_change(Watcher.match_files(self, Dir.glob('**/*')))
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_change(paths)
      templates = {}
      paths.each do |path|
        @watchers.each do |watcher|
          if target = get_target(path, watcher)
            contents = File.read(path)
            if @single_file_mode
              templates[target] = contents
            else
              dir = Pathname.new(target[:path]).dirname.to_s
              FileUtils.mkdir_p(dir) if !File.exist?(dir)
              File.open(target[:path], 'w') do |f|
                f.write("#{@options[:namespace]}['#{target[:name]}'] = #{compile(contents, target[:type])}") 
              end
            end
          end
        end
      end
      if @single_file_mode
        File.open(@options[:output], 'w') do |f|
          js = templates.map{|target,content| "#{target[:name].dump}: #{compile(content, target[:type])}" }.join(",\n")
          f.write "#{@options[:namespace]}.templates = {#{js}}"
        end
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_deletion(paths)
      matched = false
      paths.each do |path|
        @watchers.each do |watcher|
          if target = get_target(path, watcher) 
            matched = true
            FileUtils.rm target[:path] unless @single_file_mode 
          end
        end
      end

      # this is slow, but works. would be better to do a eval + series of deletes, 
      # but how to re-serialize the js object?
      run_all if @single_file_mode && matched
    end

    private
    def get_target(path, watcher)
      if match = path.match(watcher.pattern)
        subpath = match[1]
        jspath = File.join(@options[:output], "#{subpath}.js")

        {:name => subpath, 
         :type => File.extname(path).gsub(/^\./,''),
         :path => jspath} 
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
