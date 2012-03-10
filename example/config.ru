require 'bundler/setup'
require 'sinatra'
require 'omniauth'
require 'omniauth-mydigipass'


class App < Sinatra::Base
  get '/' do
    content_type 'text/html'
    <<-HTML
      <h1>Test OAuth2 with MYDIGIPASS.COM</h1>
      <script  type="text/javascript" src="https://sandbox.mydigipass.com/dp_connect.js"></script>
      <a class="dpplus-connect" data-client-id="2z4z3zn6ezuov82e4dfu73q3z" data-redirect-uri="http://localhost:3002/auth/mydigipass/callback" href="#">connect with mydigipass.com</a>
    HTML
  end

  get '/auth/:name/callback' do
    @auth = request.env['omniauth.auth']
    erb :callback
  end

  get '/auth/failure' do
    @request = request
    erb :failure
  end
end

use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :mydigipass, '2z4z3zn6ezuov82e4dfu73q3z', '1mcskxim7nomrafvfg7s36pjv',
           :client_options => OmniAuth::Strategies::Mydigipass.default_client_urls(:sandbox => true)
end

run App.new