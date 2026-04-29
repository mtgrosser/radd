class Radd::Webserver < Async::HTTP::Server
  def initialize
    endpoint = Async::HTTP::Endpoint.parse("http://#{Radd.http_host}:#{Radd.http_port}")
    # TODO: support UNIX endpoints
    # endpoint = Async::HTTP::Endpoint.parse("http://127.0.0.1")
    # endpoint.endpoint = IO::Endpoint.unix("/tmp/radd1.sock")
    middleware = Protocol::Rack::Adapter.new(Radd::App)
    super(middleware, endpoint)
  end
end
