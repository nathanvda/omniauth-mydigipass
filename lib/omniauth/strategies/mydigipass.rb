require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Mydigipass < OmniAuth::Strategies::OAuth2

      def self.default_client_urls(options = {})
        local_base_uri = options[:sandbox] ? 'https://sandbox.mydigipass.com' : 'https://mydigipass.com'
        {
          :site          => local_base_uri,
          :authorize_url => local_base_uri + '/oauth/authenticate',
          :token_url     => local_base_uri + '/oauth/token'
        }
      end


      # Give your strategy a name.
      option :name, "mydigipass"

      # for the sandbox environment, use http://sandbox.mydigipass.com
      option :base_uri, "https://mydigipass.com"

      #option :client_options, {
      #          :site          => base_uri,
      #          :authorize_url => base_uri + '/oauth/authenticate',
      #          :token_url     => base_uri + '/oauth/token'
      #        }

      option :client_options, default_client_urls


      # These are called after authentication has succeeded.
      uid { raw_info['uuid'] }

      info do
        {
          :name => "#{raw_info['first_name']} #{raw_info['last_name']}",
          :email => raw_info['email'],
          :nickname => raw_info['login'],
          :first_name => raw_info['first_name'],
          :last_name => raw_info['last_name'],
          :location => "#{raw_info['address_1']}, #{raw_info['zip']} #{raw_info['city']}, #{raw_info['country']}",
        }
      end

      extra do
        {'raw_info' => raw_info}
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/user_data').parsed
      end

      def base_uri
        default_options[:base_uri]
      end


    end
  end
end
