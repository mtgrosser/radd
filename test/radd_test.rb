require 'rubygems'
require 'open3'
require 'minitest/autorun'

class RaddTest < Minitest::Test

  def test_origin_a
    assert_dig '10.1.2.3', 'ddns.example.com'
  end

  def test_authoritative_ns
    assert_dig 'ns.example.com.', 'ddns.example.com', :NS
  end

  def test_soa
    assert_match /\Ans\.example\.com\. hostmaster\.example\.com\. \d+ 10800 1800 604800 1800\z/,
                 dig('ddns.example.com', :SOA)
  end

  def test_update
    assert_equal "OK 10.11.12.13\n", `curl --no-progress-meter --user "foobar:password" http://127.0.0.1:3003/update?ip=10.11.12.13`
    assert_dig '10.11.12.13', 'foobar.ddns.example.com'
    assert_equal "OK 10.7.33.7\n", `curl --no-progress-meter --user "foobar:password" http://127.0.0.1:3003/update?ip=10.7.33.7`
    assert_dig '10.7.33.7', 'foobar.ddns.example.com'
  end

  def test_unauthorized
    result, _ = Open3.capture2e('curl --no-progress-meter --fail --user "foobar:qwertyu" http://127.0.0.1:3003/update?ip=10.11.12.13')
    assert_match /\ 401/, result
  end

  def test_query_ip
    assert_equal "127.0.0.1\n", `curl --no-progress-meter http://127.0.0.1:3003/ip`
  end

  def test_mangled_ip
    result, _ = Open3.capture2e('curl --no-progress-meter --fail --user "foobar:password" http://127.0.0.1:3003/update?ip=410.11.12.13')
    assert_match /\ 422/, result
  end

  def test_auto_ip
    assert_equal "OK 127.0.0.1\n", `curl --no-progress-meter --user "foobar:password" http://127.0.0.1:3003/update`
  end

  private

  def assert_dig(expect, query, type = :A)
    result = dig(query, type)
    assert_equal expect, result, "Expected dig #{query} #{type} to return '#{expect}', but got '#{result}'"
  end

  def dig(query, type)
    `dig @127.0.0.1 +short -p 5300 #{query} #{type}`.strip
  end
end
