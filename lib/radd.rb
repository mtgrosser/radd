require 'yaml'
require 'sequel'
require 'resolv'
require 'bcrypt'
require 'logger'

require 'async'
require 'async/dns'
require 'async/http/server'
require 'async/http/endpoint'
require 'protocol/rack/adapter'

# require 'io/endpoint'
# require 'io/endpoint/unix_endpoint'

require_relative 'radd/version'
require_relative 'radd/errors'
require_relative 'radd/config'
require_relative 'radd/ip'
require_relative 'radd/update'
require_relative 'radd/middleware'
require_relative 'radd/nameserver'
require_relative 'radd/webserver'
require_relative 'radd/app'
require_relative 'radd/cli'

module Radd
  class << self
    def root=(path)
      @root = Pathname.new(path)
    end

    def root
      @root ||= Pathname.new(Dir.pwd)
    end

    def logger
      @logger = Logger.new(STDOUT)
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

    def serial
      Radd.db&.stat&.mtime.to_i
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
