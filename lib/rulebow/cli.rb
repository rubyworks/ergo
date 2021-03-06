module Rulebow

  ##
  # Rulebow's command line interface.
  #
  class CLI

    # Fire her up!
    def self.fire!(argv=ARGV)
      new(argv).fire!
    end

    # Initialize new instance of Rulebow::CLI.
    # If `argv` is not provided than ARGV is used.
    #
    # argv - Command line argument. [Array<String>]
    #
    # Returns nothing.
    def initialize(argv=ARGV)
      #begin
      #  require 'dotopts'
      #rescue LoadError
      #end

      @argv = Array(argv || ARGV)

      @script = nil
      @watch  = nil
      @fresh  = false
    end

    # Returns runner instance. [Runner]
    def runner
      @runner ||= (
        Runner.new(
          :script => @script,
          :fresh  => @fresh,
          :watch  => @watch
        )  
      )
    end

    # Execute command.
    #
    # command - Which command to execute.
    #
    # Returns nothing.
    def fire!(argv=ARGV)
      $DEBUG = argv.include?('--debug') || $DEBUG
      return fire if $DEBUG
      begin
        fire
      rescue => err
        puts "#{$0}: error #{err}"
      end
    end

    # Fire her up!
    def fire
      args = cli_parse

      ensure_options(args)

      #if args.first == 'init' && !runner.root?
      #  init_project(*args)
      #end

      case @command
      when :list
        print_rules(*args)
      when :help
        print_help(*args)
      else
        runner.run(args.first)
      end
    end

    # Parse command line arguments with just the prettiest
    # little CLI parser there ever was.
    def cli_parse
      @command = nil

      cli @argv,
        "-R --rules"  => lambda{ @command = :list },
        "-H --help"   => lambda{ @command = :help },
        "-a --auto"   => method(:watch=),
        "-f --fresh"  => method(:fresh!),
        "-s --script" => method(:script=),
        "-D --debug"  => method(:debug!)
    end

    #
    def print_help(*names)
      puts "-R --rules            list ruleset descriptions"
      puts "-H --help             list these help options"
      puts "-a --auto [TIME]      autorun every so many seconds"
      puts "-f --fresh            clear digest for fresh run"
      puts "-s --script [SCRIPT]  use alternate script"
      puts "-D --debug            extra error information"
    end

    #
    def ensure_options(args)
      erropts = args.select{ |a| a.start_with?('-') }
      unless erropts.empty?
        raise "unsupported options #{erropts.join(' ')}" 
      end
    end

    # Shall we make a fresh start of it, and remove all digests?
    #
    # Returns [Boolean]
    def fresh?
      @fresh
    end

    # Set fresh flag to true.
    #
    # Returns [Boolean]
    def fresh! 
      @fresh = true
    end

    # Is debug mode on?
    #
    # Returns [Boolean]
    def debug?
      $DEBUG
    end

    # Set debug flag to true.
    #
    # Returns [Boolean]
    def debug! 
      $DEBUG = true
    end
  
    # Set the "watch" period --the rate at which
    # autofiring of occurs.
    #
    # Returns [Fixnum[
    def watch=(seconds)
      @watch = seconds.to_i
    end

    # Use alternate rulebow script.
    #
    # Returns [Array]
    def script=(script)
      @script = script.to_s
    end

    # Initialize project for rulebow.
    #
    # Returns nothing.
    def init_project(*args)
      # anything to do?
    end

    # Print out a list of availabe manual triggers.
    #
    # Returns nothing.
    def print_rules(*names)
      names = nil if names.empty?
      puts "(#{runner.root})"
      runner.rulesets.each do |name, set|
        next unless names.member?(name.to_s) if names
        print "#{name}"
        print " (#{set.chain.join(' ')})" unless set.chain.empty?
        puts
        set.docs.each_with_index do |d, i|
          puts "  * #{d}"
        end
      end

      #exit
    end

  end

end
