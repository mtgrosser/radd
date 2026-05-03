module Radd
  class Nameserver < Async::DNS::Server

    def initialize
      super(Async::DNS::Endpoint.for(Radd.dns_host, port: Radd.dns_port))
    end

    def process(name, resource_class, transaction)
      name = Resolv::DNS::Name.create(name.downcase)
      # NOTE: do not use case..when, as resource classes are not identical
      if Resolv::DNS::Resource::IN::A == resource_class
        if Radd.mname == name || Radd.origin == name
          return respond_a(transaction, Radd.ip)
        elsif name.subdomain_of?(Radd.origin)
          return respond_a(transaction, Radd.query(name))
        end
      elsif resource_class <= Resolv::DNS::Resource::SOA && Radd.origin == name
        # mname, rname, serial, refresh, retry_, expire, minimum
        return transaction.respond!(Radd.mname, Radd.rname, Radd.serial, 10800, 1800, 604800, 1800)
      elsif resource_class <= Resolv::DNS::Resource::NS && Radd.origin == name
        return transaction.respond!(Radd.mname)
      end
      transaction.fail!(:Refused)
    end

    private

    def respond_a(transaction, ip)
      if ip
        transaction.respond!(ip, ttl: Radd.ttl)
      else
        transaction.fail!(:NXDomain)
      end
    end

  end
end
