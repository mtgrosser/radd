module Radd
  class Nameserver < Async::DNS::Server

    def initialize
      super(Async::DNS::Endpoint.for(Radd.dns_host, port: Radd.dns_port))
    end

    def process(name, resource_class, transaction)
      name = Resolv::DNS::Name.create(name.downcase)
      type = query_type(resource_class)
      if Radd.origin == name
        case type
        when :A   then return respond_a(transaction, Radd.ip)
        when :SOA then return transaction.respond!(Radd.mname, Radd.rname, Radd.serial, 10800, 1800, 604800, 1800)
        when :NS  then return transaction.respond!(Radd.mname)
        end
      elsif name.subdomain_of?(Radd.origin)
        case type
        when :A then return respond_a(transaction, Radd.query(name))
        else
          return transaction.fail!(:NoError)
        end
      end
      transaction.fail!(:Refused)
    end

    private

    def query_type(resource_class)
      if Resolv::DNS::Resource::IN::A == resource_class
        :A
      elsif resource_class <= Resolv::DNS::Resource::SOA
        :SOA
      elsif resource_class <= Resolv::DNS::Resource::NS
        :NS
      elsif resource_class <= Resolv::DNS::Resource::MX
        :MX
      elsif resource_class <= Resolv::DNS::Resource::IN::AAAA
        :AAAA
      else
        :UNKNOWN
      end
    end

    def respond_a(transaction, ip)
      if ip
        transaction.respond!(ip, ttl: Radd.ttl)
      else
        transaction.fail!(:NXDomain)
      end
    end

  end
end
