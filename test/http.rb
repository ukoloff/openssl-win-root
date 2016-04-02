require 'net/http'

class TestEngine < Minitest::Test

  def test_http
    assert_raises(OpenSSL::SSL::SSLError) do
      Net::HTTP.get URI 'https://ya.ru'
    end
    require 'openssl/win/root'
    Net::HTTP.get URI 'https://ya.ru'
  end

end
