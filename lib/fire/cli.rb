module Fire

  ##
  # Fire's command line interface.
  #
  class CLI

    # Fire her up!
    def self.run(argv=ARGV)
      new(argv).run
    end

    # Fire her up in autorun mode!
    def self.autorun(argv=ARGV)
      new(argv).autorun
    end

    # Initialize new instance of Fire::CLI.
    def initialize(argv=ARGV)
      @argv = argv
    end

    # Returns session instance. [Session]
    def session
      @session ||= Session.new(:watch=>@watch)
    end

    # Fire her up!
    def run
      args = cli_parse
      case @command
      when :list
        list_rules(*args)
      else
        session.run(args)
      end
    end

    # Fire her up in autorun mode!
    def autorun
      args = cli_parse
      session.autorun(args)
    end

    # Parse command line arguments with just the prettiest
    # little CLI parser there ever was.
    def cli_parse
      @command = nil

      cli @argv,
        "-R" => lambda{@command = :list},
        "-w" => method(:watch)
    end

    # Print out a list of availabe manual triggers.
    def list_rules(*books)
      puts "(#{session.root})"
      if books.empty?
        session.rules.each do |rule|
          next if rule.to_s.strip == ""
          puts "* #{rule}"
        end
      else
        session.rules.each do |rule|
          next unless books.any?{ |b| rule.book?(b) }
          next if rule.to_s.strip == ""
          puts "* #{rule}"
        end
      end
      exit
    end

    # Set the watch wait period.
    def watch(seconds)
      @watch = seconds 
    end

  end

end
