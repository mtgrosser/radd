require 'optparse'

module Radd::Cli

  class << self

    def load_config
      config = {}
      parser = OptionParser.new
      parser.banner = 'Usage: radd --config [FILE]'
      parser.on('--config FILE', 'Config file') do |file|
        config['file'] = file
      end

      parser.parse!

      Radd.configure!(config['file'])
    end

    def start
      load_config
      puts "Starting Radd server for #{Radd.domain}"

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
