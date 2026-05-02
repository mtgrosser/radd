class Radd::Nameserver < Async::DNS::Server
  def initialize
    super(Async::DNS::Endpoint.for(Radd.dns_host, port: Radd.dns_port))
  end
  
  def process(name, resource_class, transaction)
    name = name.downcase
    case resource_class
    when Resolv::DNS::Resource::IN::A
      ip = Radd.domain == name ? Radd.ip : Radd.query(name)
      return transaction.respond!(ip, ttl: Radd.ttl) if ip
    when Resolv::DNS::Resource::IN::SOA
      return transaction.respond!(Radd.mname, Radd.rname, Radd.serial, 10800, 1800, 604800, 1800)
    end
    transaction.fail!(:NXDomain)
  end
end
