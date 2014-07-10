require 'byebug'
require 'pathname'
require 'sequel'
require 'resolv'
require 'bcrypt'

module Radd
  class << self
    def root
      Pathname.new(__FILE__).dirname
    end

    def zone
      root.join('zone')
    end

    def base
      zone.join('radd.base')
    end

    def file
      data.join('radd.zone')
    end

    def valid_ip?(ip)
      ip && ip.match(Resolv::IPv4::Regex)
    end

    def authorized?(name, password)
      return false unless record = Record.where(name: name).first
      BCrypt::Password.new(record.password_hash) == password
    end
  end
end

DB = Sequel.sqlite(Radd.root.join('db', 'radd.sqlite3').to_s)

Radd::IP = Proc.new do |env|
  [200, {"Content-Type" => "text/plain"}, [env['REMOTE_ADDR']]]
end

module Radd
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
      raise InvalidRequest unless ip
      record.ip = ip
      record.save
      result = update_zone
      [200, {'Content-Type' => 'text/plain'}, ["OK\n#{result}"]]
    rescue RaddError => boom
      status = case boom
      when InvalidRequest, Sequel::ValidationFailed then 422
      when Forbidden then 403
      else
        500
      end
      respond status, boom.message
    rescue Exception => e
      respond 500, e.message
    end

    private

    def name
      env['REMOTE_USER']
    end

    def respond(status, body)
      [status, {'Content-Type' => 'text/plain'}, ["#{body}\n"]]
    end

    def update_zone
      zonefile = Radd.base.read
      zonefile << "\n; BEGIN radd dynamic hosts\n"
      records = Record.active.all
      tab = [records.map(&:name).map(&:size).max, 30].compact.max
      records.each do |record|
        zonefile << "#{record.name.ljust(tab)} IN      A       #{record.ip}\n"
      end
      zonefile
    end
  end
end
