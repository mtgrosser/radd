module Radd

  class << self
    attr_reader :origin, :ip, :db, :http_host, :http_port, :dns_host, :dns_port, :ttl,
                :mname, :rname
    
    def configure!(file, skip_models: false, skip_db: false)
      file_path = Pathname.new(file || 'radd.yml')
      file_path = Radd.root + file_path unless file_path.absolute?
      raise ConfigurationError, "could not open config file #{file_path}" unless file_path.file?
      config = YAML.load(file_path.read)
      raise ConfigurationError, 'origin missing' unless config['origin']
      @origin = config['origin']
      raise ConfigurationError, 'invalid IP' unless Radd.valid_ip?(config['ip'])
      @ip = config['ip']
      uri = URI.parse("http://#{config['http']}")
      @http_host = uri.host || '127.0.0.1'
      @http_port = uri.port || 3003
      uri = URI.parse("dns://#{config['dns']}")
      @dns_host = uri.host || '0.0.0.0'
      @dns_port = uri.port || 53
      raise ConfigurationError, 'invalid TTL' if config['ttl'] && config['ttl'] < 1
      @ttl = config['ttl'] || 300
      raise ConfigurationError, 'master name missing' unless config['mname']
      @mname = Resolv::DNS::Name.create(config['mname'])
      @rname = Resolv::DNS::Name.create(config['rname'] || "hostmaster@#{origin}")
      db_path = Pathname.new(config['db'] || 'radd.sqlite3')
      db_path = Radd.root + db_path unless db_path.absolute?
      @db = db_path
      raise ConfigurationError, 'invalid database' if !skip_db && !Radd.db.file?
      #
      # Late loading required by Sequel architecture
      #
      require_relative 'db'
      require_relative 'record' unless skip_models
    end

    # Check whether +ip+ is a valid IP address string
    def valid_ip?(ip)
      !!(ip && ip.match(Resolv::IPv4::Regex))
    end
  end

end
