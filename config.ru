require_relative 'radd'

map '/ip' do
  run Radd::IP
end

map '/update' do
  use Rack::Auth::Basic, 'Authorization required' do |user, password|
    Radd.authorized?(user, password)
  end
  run Radd::Update
end
