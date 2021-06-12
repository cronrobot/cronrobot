
require 'net/http'
require 'uri'

class JsonWebToken
  def initialize(opts = {})
    @opts = opts.clone
  end

  def verify(token)
    JWT.decode(token, nil,
               true, # Verify the signature of this token
               algorithms: 'RS256',
               iss: @opts[:tenant_url],
               verify_iss: true,
               aud: @opts[:audience],
               verify_aud: true) do |header|
      jwks_hash[header['kid']]
    end
  end

  def jwks_hash
    jwks_raw = Net::HTTP.get URI("#{@opts[:tenant_url]}.well-known/jwks.json")
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])

    Hash[
      jwks_keys
      .map do |k|
        [
          k['kid'],
          OpenSSL::X509::Certificate.new(
            Base64.decode64(k['x5c'].first)
          ).public_key
        ]
      end
    ]
  end
end