module Radd

  class << self
    def configure!(file)
      file_path = Pathname.new(file || 'radd.yml')
      file_path = Radd.root + file_path unless file_path.absolute?
      raise Radd::ConfigurationError, "could not open config file #{file_path}" unless file_path.file?
      @config = YAML.load(file_path.read).slice(*%w[domain ip host dns_port http_port db])
      raise Radd::ConfigurationError, 'domain missing' unless Radd.domain
      raise Radd::ConfigurationError, 'invalid IP' unless Radd.valid_ip?(Radd.ip)
      db_path = Pathname.new(@config.delete('db') || 'db/radd.sqlite3')
      db_path = Radd.root + db_path unless db_path.absolute?
      @config['db'] = db_path
      raise Radd::ConfigurationError, 'invalid database' unless Radd.db.file?
      # Late loading required by Sequel architecture
      require_relative 'db'
      require_relative 'record'
    end
    
    def domain
      @config['domain']
    end

    def ip
      @config['ip']
    end
    
    def db
      @config['db']
    end
    
    def host
      @config['host'] || '127.0.0.1'
    end

    def dns_port
      @config['dns_port'] || 5300
    end
    
    def http_port
      @config['http_port'] || 3000
    end

    # Check whether +ip+ is a valid IP address string
    def valid_ip?(ip)
      !!(ip && ip.match(Resolv::IPv4::Regex))
    end
  end
  
end
