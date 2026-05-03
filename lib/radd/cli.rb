require 'optparse'

module Radd::Cli

  COMMANDS = %w[help setup add delete list start].freeze

  class << self

    def load_config(**opts)
      config = {}
      parser = OptionParser.new
      parser.banner = 'Usage: radd COMMAND [--config FILE]'
      parser.on('--config FILE', 'Config file') do |file|
        config['file'] = file
      end

      parser.parse!

      Radd.configure!(config['file'], **opts)
    end

    def run
      command = ARGV.shift
      if COMMANDS.include?(command)
        send(command)
      elsif command.nil?
        help
        exit 1
      elsif '--help' == command
        help
      else
        puts "Unknown command #{command}"
        exit 1
      end
    end

    def help
      puts <<~EOS
        Usage:
          radd COMMAND [--config FILE]

        You must specify one of the following commands:

          setup        Create the database
          add          Add new record
          delete       Delete record
          list         List available records
          start        Run the server
      
      EOS
    end

    def setup
      require_relative 'schema'
      load_config(skip_db: true, skip_models: true)
      Radd::Schema.create
    end

    def add
      load_config
      print "Enter name: "
      name = STDIN.gets.chomp
      print "Password: "
      password = STDIN.gets.chomp
      print "Re-type password: "
      password_confirmation = STDIN.gets.chomp
      raise "Password mismatch!" unless password == password_confirmation
      record = Radd::Record.new(password: password)
      record.name = name
      record.save
      puts "Added record '#{name}'\n"
    end

    def delete
      load_config
      print "Enter name: "
      name = STDIN.gets.chomp
      if record = Radd::Record.where(name: name).first
        print "Do you really want to delete #{name} (y/N)?"
        confirm = STDIN.gets.chomp
        if 'y' == confirm
          record.delete
          puts "Record #{name} deleted"
        end
      else
        puts "Record #{name} not found"
      end
    end

    def list
      load_config
      puts
      records = Radd::Record.all
      tab = [records.map(&:name).map(&:size).max, 24].compact.max
      records.each do |record|
        puts "#{record.name.ljust(tab)}  #{record.ip.to_s.ljust(15)}  #{record.updated_at || 'never updated'}\n"
      end
      puts
    end

    def start
      load_config
      puts "Starting Radd server for #{Radd.origin}"

      dns, http = Radd::Nameserver.new, Radd::Webserver.new

      Async do
        dns_task, http_task = dns.run, http.run
        watchdog = Async do
          sleep(1) while !http_task.failed? && !dns_task.failed?
          puts "Task failed!"
          exit(1)
        end
      end
    end

  end

end
