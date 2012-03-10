# OmniAuth Mydigipass.com

This is an OmniAuth strategy for authenticating with MYDIGIPASS.COM.

If you want to integrate your website with MYDIGIPASS.COM, you will need to
sign up on http://developer.mydigipass.com and connect your site there.
There you will get a `client_id` and `client_secret` you need to fill in here.


## Basic Usage

If you are testing your application in the sandbox environment, write

    use OmniAuth::Builder do
      provider :mydigipass, ENV['MYDIGIPASS_CLIENT_ID'], ENV['MYDIGIPASS_CLIENT_SECRET'],
                            :client_options => OmniAuth::Strategies::Mydigipass.default_client_urls(:sandbox => true)
    end

Once your application goes in production, you can just write:

    use OmniAuth::Builder do
      provider :mydigipass, ENV['MYDIGIPASS_CLIENT_ID'], ENV['MYDIGIPASS_CLIENT_SECRET']
    end

## Example Application

I have added a small working example application, check it out how it should work. To integrate into rails you should

* add the

## Example Integrating with Rails

Inside your `config/application.rb` add the following (e.g. at the bottom, inside the configuration block) :

    # enable omniauth strategies
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :mydigipass, APP_CONFIG[:client_id], APP_CONFIG[:client_secret]
    end

And then you just have to make sure you have something listening at `/auth/:provider/callback`.
Suppose you add the following routes:

  match '/auth/:provider/callback', :to => 'home#auth_create'
  match '/auth/failure', :to => 'home#auth_failure'

Then, inside your `HomeController` you could write:

    def auth_failure
      set_flash_message(:notice, "OAuth error: #{params[:message]}")
      redirect_to root_path
    end

    def auth_create
      user = User.find_or_create_from_auth_hash(request.env['omniauth.auth'].with_indifferent_access)
      logger.debug "Found or created user: #{user.email} [#{user.id}]"
      if user.sign_in_count == 0
        set_flash_message(:notice, "Welcome #{user.email}, thank you for signing up using your dP+ account!")
      else
        set_flash_message(:notice, "Succesfully logged in!")
      end
      sign_in(:user, user, :bypass => true)
      redirect_to dashboard_path
    end

When a user signs in through MYDIGIPASS.COM, it could be a new user (signing up), or an existing user.
The function `find_or_create_from_auth_hash` handles that for me:

    def self.from_auth_hash(auth_hash)
      logger.debug "User.from_auth_hash: auth_hash = #{auth_hash.inspect} "
      received_uuid = auth_hash[:extra][:raw_info][:uuid]
      received_email = auth_hash[:extra][:raw_info][:email]

      user = User.find_by_uuid(received_uuid) || User.find_by_email(received_email)
      user = user.nil? ? create_from_auth_hash(received_uuid, received_email) : prevent_login_with_normal_password(user, received_uuid)
    end

I try to find the user, by `uuid` or `email`. If I find the user by `uuid`, she has logged on before with MYDIGIPASS.COM
If I find a matching mail, link the uuid to that user. If I do not find a user, create one with the given `email` and `uuid`.
I also made sure that users can then only login with their MYDIGIPASS.COM and no longer normally, but that is optional of course.

## License

Copyright (c) 2012 Nathan Van der Auwera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
