module Radd
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      env["rack.request"] = Rack::Request.new(env)
      @app.call(env)
    end
  end
end
