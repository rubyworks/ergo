module Ergo

  ##
  # Rule book provides namespace isolation for states, rules and methods.
  #
  # TODO: There are some minor namespace issues with this implementation.
  #       We don't necessarily want a rule block to be able to
  #       call #rule. However, the scoping is a bit complicated,
  #       so it's an acceptable niggle for now.
  #
  class Book < Module

    # Instantiate new book.
    #
    # Arguments
    #    system - The system to which this book belongs. [System]
    #    name   - Name of the book.
    #
    # Yields the script defining the books rules.
    def initialize(system, name, &block)
      extend ShellUtils
      extend system
      extend self

      @scripts = []
      @rules   = []
      @states  = {}

      @name, @chain = parse_name(name)

      @ignore  = system.ignore
      @session = system.session

      clear_rule_options

      module_eval(&block) if block
    end

    # Book name
    attr :name

    # Toolchain (dependencies)
    attr :chain

    # Current session.
    attr :session

    # Rule scripts.
    attr :scripts

    # Array of defined states.
    attr :states

    # Array of defined rules.
    attr :rules

    # Import from another file, or glob of files, relative to project root.
    #
    # TODO: Should importing be relative to the importing file?
    #
    # Returns nothing.
    def import(*globs)
      globs.each do |glob|
        #if File.relative?(glob)
        #  dir = Dir.pwd  #session.root #File.dirname(caller[0])
        #  glob = File.join(dir, glob)
        #end
        Dir[glob].each do |file|
          next unless File.file?(file)  # add warning
          next if @scripts.include?(file)
          @scripts << file
          module_eval(File.read(file), file)
        end
      end
    end

    # Add paths to be ignored in file rules.
    #
    # globs - List of file globs. [Array<String>]
    #
    # Returns [Array<String>]
    def ignore(*globs)
      @ignore.concat(globs) unless globs.empty?
      @ignore
    end

    # Replace globs in ignore list.
    #
    # globs - List of file globs. [Array<String>]
    #
    # Returns [Array<String>]
    def ignore!(*globs)
      @ignore.replace(globs)
      @ignore
    end

    # Define a named state. States define conditions that are used to trigger
    # rules. Named states are kept in a hash table to ensure that only one state
    # is ever defined for a given name. Calling state again with the same name
    # as a previously defined state will redefine the condition of that state.
    #
    # Examples
    #   state :no_rdocs? do
    #     files = Dir.glob('lib/**/*.rb')
    #     FileUtils.uptodate?('doc', files) ? files : false
    #   end
    #
    # Returns nil if state name is given. [nil]
    # Returns State in no name is given. [State]
    def state(name=nil, &condition)
      if name
        if condition
          @states[name.to_sym] = condition
          define_method(name) do |*args|
            state = @states[name.to_sym]
            State.new{ states[name.to_sym].call(*args) }
          end
        else
          raise ArgumentError
        end
      else
        State.new{ condition.call(*args) }
      end
    end

    # Define a file state.
    #
    # Returns [FileState]
    def file(pattern)
      FileState.new(pattern)
    end

    # Define an environment state.
    #
    # Examples
    #   env('PATH'=>/foo/)
    #
    # Returns [State]
    def env(name_to_pattern)
      State.new do
        name_to_pattern.any? do |name, re|
          re === ENV[name.to_s]  # or `all?` instead?
        end
      end
    end

    # Define a rule. Rules are procedures that are tiggered 
    # by logical states.
    #
    # Examples
    #   rule no_rdocs do |files|
    #     sh "rdoc --output doc/rdoc " + files.join(" ")
    #   end
    #
    # Returns [Rule]
    def rule(state, &procedure)
      case state
      when String, Regexp
        state = file(state)
      when Symbol
        # TODO: Is this really the best idea?
        #@states[state.to_sym]
      end
      rule = Rule.new(state, get_rule_options, &procedure)
      @rules << rule
      clear_rule_options
      rule
    end

    # Check a name state.
    #
    # Returns [Array,Boolean]
    def state?(name, *args)
      @states[name.to_sym].call(*args)
    end

    # Set rule description. The next rule defined will get the most
    # recently defined description attached to it.
    #
    # Returns [String]
    def desc(description)
      @_desc = description
    end

    # Bookmark the rule.
    #
    # Returns nothing.
    def mark(*names)
      @_mark.concat(names)
    end
    alias :bookmark :mark

    # Provide a separate subspace for states and rules.
    # Spaces are added to the rules list to preserve order of operation.
    #
    # Return [Space]
    def space(&block)
      s = Space.new(self, &block)
      @rules << s
      s
    end

    #
    #
    def private(*methods)
      @_priv = true
      super(*methods)   # TODO: why doesn't this work as expected?
    end

    # Issue notification.
    #
    # Returns nothing.
    def notify(message, options={})
      title = options.delete(:title) || 'Ergo Notification'
      Notify.notify(title, message.to_s, options)
    end

  private

    def get_rule_options     
      { :desc=>@_desc, :mark=>@_mark, :private=>@_priv }
    end

    def clear_rule_options
      @_mark = [name].compact
      @_desc = nil
      @_priv = false
    end

    #
    #
    #
    def parse_name(name)
      if Hash === name
        raise ArgumentError if name.size > 1       
        list = [name.values].flatten.map{ |b| b.to_sym }
        name = name.keys.first
      else
        list = []
      end
      return name.to_sym, list
    end
  end

end


