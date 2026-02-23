require 'optparse'

module Radd::Cli

  class << self

    def start
      config = {}
      parser = OptionParser.new
      parser.banner = 'Usage: radd -i IP -d DOMAIN [options]'
      parser.on('--ip IP', 'Public IP address') do |ip|
        config['ip'] = ip
      end
      parser.on('--domain DOMAIN', 'Root FQDN') do |domain|
        config['domain'] = domain
      end
      parser.on('--http-port [PORT]', 'HTTP port') do |port|
        config['http_port'] = port
      end
      parser.on('--dns-port [PORT]', 'DNS port') do |port|
        config['dns_port'] = port
      end
      parser.parse!

      Radd.configure!(config)
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
