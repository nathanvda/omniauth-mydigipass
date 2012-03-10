require 'spec_helper'
require 'omniauth-mydigipass'

describe OmniAuth::Strategies::Mydigipass do
  subject do
    OmniAuth::Strategies::Mydigipass.new(nil, @options || {})
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'should have the correct mydigipass.com site' do
      subject.client.site.should eq("https://mydigipass.com")
    end

    it 'should have the correct authorization url' do
      subject.client.options[:authorize_url].should eq("https://mydigipass.com/oauth/authenticate")
    end

    it 'should have the correct token url' do
      subject.client.options[:token_url].should eq('https://mydigipass.com/oauth/token')
    end
  end

  describe '#callback_path' do
    it 'should have the correct callback path' do
      subject.callback_path.should eq('/auth/mydigipass/callback')
    end
  end

  context "when connecting to the sandbox" do
    it 'should have the correct mydigipass.com site' do
      @options = { :client_options => OmniAuth::Strategies::Mydigipass.default_client_urls(:sandbox => true) }
      subject.client.site.should eq("https://sandbox.mydigipass.com")
    end

  end
end