class Radd::Nameserver < Async::DNS::Server
  def initialize
    super(Async::DNS::Endpoint.for(Radd.dns_host, port: Radd.dns_port))
  end
  
  def process(name, resource_class, transaction)
    name = name.downcase
    if Resolv::DNS::Resource::IN::A == resource_class
      if Radd.domain == name
        ip = Radd.ip
      else
        ip = Radd.query(name)
      end
    end
    return transaction.respond!(ip, ttl: Radd.ttl) if ip
    transaction.fail!(:NXDomain)
  end
end
