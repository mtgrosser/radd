class Radd::Webserver < Async::HTTP::Server
  def initialize
    endpoint = Async::HTTP::Endpoint.parse("http://#{Radd.host}:#{Radd.http_port}")
    middleware = Protocol::Rack::Adapter.new(Radd::App)
    super(middleware, endpoint)
  end
end
