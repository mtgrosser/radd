module Radd
  # IP address query responder
  IP = Proc.new do |env|
    [200, {"Content-Type" => "text/plain"}, ["#{env['REMOTE_ADDR']}\n"]]
  end
end
