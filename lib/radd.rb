require 'yaml'
require 'sequel'
require 'resolv'
require 'bcrypt'

require 'async'
require 'async/dns'
require 'async/http/server'
require 'async/http/endpoint'
require 'protocol/rack/adapter'

require_relative 'radd/version'
require_relative 'radd/ip'
require_relative 'radd/db'
require_relative 'radd/record'
require_relative 'radd/update'
require_relative 'radd/nameserver'
require_relative 'radd/webserver'
require_relative 'radd/app'

module Radd
  class RaddError < StandardError; end
  class ConfigurationError < StandardError; end
  class Forbidden < RaddError; end
  class InvalidRequest < RaddError; end
  class UpdateError < RaddError; end

  class << self
    def configure!(config)
      @config = config.slice(*%w[domain ip host dns_port http_port])
      raise Radd::ConfigurationError, 'domain missing' unless Radd.domain
      raise Radd::ConfigurationError, 'invalid IP' unless Radd.valid_ip?(Radd.ip)
    end
    
    def domain
      config['domain']
    end

    def ip
      config['ip']
    end
    
    def host
      config['host'] || '127.0.0.1'
    end

    def dns_port
      config['dns_port'] || 5300
    end
    
    def http_port
      config['http_port'] || 3000
    end

    # Check whether +ip+ is a valid IP address string
    def valid_ip?(ip)
      !!(ip && ip.match(Resolv::IPv4::Regex))
    end

    # Check whether +name+ is authorized with +password+
    def authorized?(name, password)
      return false unless record = Record.where(name: name).first
      BCrypt::Password.new(record.password_hash) == password
    end

    # Query the database for +fqdn+
    def query(fqdn)
      return unless fqdn
      return unless name = fqdn2name(fqdn)
      return unless record = Record.active.where(name: name).first
      record.ip
    end
    
    def run
      
    end

    private

    def config
      @config
    end

    def fqdn2name(fqdn)
      if match = fqdn.downcase.match(/\A([a-z0-9-]{1,63})\.#{Regexp.escape(domain)}\z/)
        match.captures[0]
      end
    end
  end
end
