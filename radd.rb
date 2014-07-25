require 'pathname'
require 'yaml'
require 'sequel'
require 'resolv'
require 'bcrypt'
require 'rubydns'

DB = Sequel.sqlite(Pathname.new(__FILE__).dirname.join('db', 'radd.sqlite3').to_s)

module Radd
  class RaddError < StandardError; end
  class ConfigurationError < StandardError; end
  class Forbidden < RaddError; end
  class InvalidRequest < RaddError; end
  class UpdateError < RaddError; end

  CONFIG = YAML.load(Pathname.new(__FILE__).dirname.join('radd.yml').read)

  class << self
    def domain
      CONFIG['domain']
    end

    def ip
      CONFIG['ip']
    end

    def port
      CONFIG['port'] || 5300
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

    private

    def fqdn2name(fqdn)
      if match = fqdn.downcase.match(/\A([a-z0-9-]{1,63})\.#{Regexp.escape(domain)}\z/)
        match.captures[0]
      end
    end
  end

  # IP address query responder
  IP = Proc.new do |env|
    [200, {"Content-Type" => "text/plain"}, [env['REMOTE_ADDR']]]
  end

  class RaddError < StandardError; end
  class Forbidden < RaddError; end
  class InvalidRequest < RaddError; end
  class UpdateError < RaddError; end

  class Record < Sequel::Model
    class << self
      def active
        exclude(ip: nil)
      end
    end

    def password=(password)
      self.password_hash = BCrypt::Password.create(password)
    end

    def validate
      super
      errors.add(:name, "is invalid") if !name || !name.match(/\A[a-z0-9]([A-z0-9_\-]*)\z/)
      errors.add(:ip,   "is invalid") if ip && !Radd.valid_ip?(ip)
    end

    def before_save
      super
      self.updated_at = Time.now
    end
  end

  class Update
    attr_reader :env

    def self.call(env)
      new(env).call
    end

    def initialize(env)
      @env = env
    end

    def record
      @record ||= Record.where(name: name).first
    end

    def ip
      addr = env['REMOTE_ADDR']
      addr && Radd.valid_ip?(addr) && addr
    end

    def call
      raise Forbidden unless record
      raise InvalidRequest.new('Invalid IP address') unless ip
      record.ip = ip
      record.save
      [200, {'Content-Type' => 'text/plain'}, ["OK #{ip}"]]
    rescue RaddError => boom
      status = case boom
      when InvalidRequest, Sequel::ValidationFailed then 422
      when Forbidden then 403
      else
        500
      end
      respond status, "ERROR #{boom.message}"
    rescue Exception => e
      respond 500, "ERROR"
    end

    private

    def name
      env['REMOTE_USER']
    end

    def respond(status, body)
      [status, {'Content-Type' => 'text/plain'}, ["#{status} #{body}\n"]]
    end

  end
end

class Radd::Server < RubyDNS::Server
  def process(name, resource_class, transaction)
    name = name.downcase
    if Resolv::DNS::Resource::IN::A == resource_class
      if Radd.domain == name
        ip = Radd.ip
      else
        ip = Radd.query(name)
      end
    end
    return transaction.respond!(ip) if ip
    transaction.fail!(:NXDomain)
  end
end

raise Radd::ConfigurationError, 'domain missing from radd.yml' unless Radd.domain
raise Radd::ConfigurationError, 'invalid ip in radd.yml' unless Radd.valid_ip?(Radd.ip)
puts "Starting Radd server for #{Radd.domain} on #{Radd.ip}:#{Radd.port}"

EventMachine.run do
  Radd::Server.new({}).run(listen: [[:udp, Radd.ip, Radd.port], [:tcp, Radd.ip, Radd.port]])
end
