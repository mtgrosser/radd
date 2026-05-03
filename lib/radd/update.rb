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
      @ip ||= begin
        addr = env['rack.request'].params['ip'] || remote_ip
        addr && Radd.valid_ip?(addr) && addr
      end
    end

    def remote_ip
      addr = env['rack.request'].ip
      addr && Radd.valid_ip?(addr) && addr
    end

    def call
      raise Forbidden unless record
      raise InvalidRequest.new('Invalid IP address') unless ip
      record.ip = ip
      record.save
      Radd.logger.info "Updated record #{record.name} to #{ip} from #{remote_ip}"
      [200, {'Content-Type' => 'text/plain'}, ["OK #{ip}\n"]]
    rescue RaddError => boom
      status = case boom
      when InvalidRequest, Sequel::ValidationFailed then 422
      when Forbidden then 403
      else
        500
      end
      Radd.logger.error boom
      respond status, "ERROR #{boom.message}"
    rescue Exception => e
      Radd.logger.error e
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
