module Radd
  class Nameserver < Async::DNS::Server

    def initialize
      super(Async::DNS::Endpoint.for(Radd.dns_host, port: Radd.dns_port))
    end

    def process(name, resource_class, transaction)
      name = name.downcase
      # NOTE: do not use case..when, as resource classes are not identical
      if Resolv::DNS::Resource::IN::A == resource_class
        ip = [Radd.mname, Radd.origin].include?(name) ? Radd.ip : Radd.query(name)
        return transaction.respond!(ip, ttl: Radd.ttl) if ip
      elsif resource_class <= Resolv::DNS::Resource::SOA && Radd.origin == name
        # mname, rname, serial, refresh, retry_, expire, minimum
        return transaction.respond!(Radd.mname, Radd.rname, Radd.serial, 10800, 1800, 604800, 1800)
      elsif resource_class <= Resolv::DNS::Resource::NS && Radd.origin == name
        return transaction.respond!(Radd.mname)
      end
      transaction.fail!(:NXDomain)
    end
  end
end
