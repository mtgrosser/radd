module Radd
  # IP address query responder
  IP = Proc.new do |env|
    [200, {"Content-Type" => "text/plain"}, ["#{env['rack.request'].ip}\n"]]
  end
end
