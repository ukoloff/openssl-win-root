require 'net/http'

class TestEngine < Minitest::Test

  WWW='https://www.appveyor.com/'

  def test_http
    assert_raises(OpenSSL::SSL::SSLError) do
      Net::HTTP.get URI WWW
    end
    require 'openssl/win/root'
    Net::HTTP.get URI WWW
  end

end
