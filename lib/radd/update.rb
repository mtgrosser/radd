module Radd
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
