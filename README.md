# OmniAuth Mydigipass.com

This is an OmniAuth strategy for authenticating with MYDIGIPASS.COM.

If you want to integrate your website with MYDIGIPASS.COM, you will need to
sign up on [developer.mydigipass.com](http://developer.mydigipass.com) and connect your site there.
You will need to specify a callback url, which with this gem should be something like `http://localhost:3000/auth/mydigipass/callback`.

Then you will get a `client_id` and `client_secret` you need to fill in here.



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

I have added a small working example application, using Sinatra. Check it out in the `example` folder. To make it work just type `rackup` in the folder.

## Example Integrating with Rails

Add an initializer `mydigipass.rb` containing your application specific configuration:

```ruby
# MYDIGIPASS.COM OAuth configuration

if Rails.env.production?
  MDP_CLIENT_ID="<your-production-client-id>"
  MDP_CLIENT_SECRET="<your-production-client-secret>"
  MDP_CALLBACK_URL="<your-production-base-url>/auth/mydigipass/callback"
  MDP_JS="https://mydigipass.com/dp_connect.js"
else
  MDP_CLIENT_ID="<your-sandbox-client-id>"
  MDP_CLIENT_SECRET="<your-sandbox-client-secret>"
  MDP_CALLBACK_URL="http://localhost:3000/auth/mydigipass/callback"
  MDP_JS="https://sandbox.mydigipass.com/dp_connect.js"
end
```

Inside your `config/application.rb` add the following (e.g. at the bottom, inside the configuration block) :

```ruby
    # enable omniauth strategies
    Rails.application.config.middleware.use OmniAuth::Builder do
      if Rails.env.production?
        provider :mydigipass, MDP_CLIENT_ID, MDP_CLIENT_SECRET
      else
        provider :mydigipass, MDP_CLIENT_ID, MDP_CLIENT_SECRET,
                 :client_options => OmniAuth::Strategies::Mydigipass.default_client_urls(:sandbox => true)
      end
    end
```

And then you just have to make sure you have something listening at `/auth/:provider/callback`.
Suppose you add the following routes:

  match '/auth/:provider/callback', :to => 'home#auth_create'
  match '/auth/failure', :to => 'home#auth_failure'


Then, inside your `HomeController` you could write:

```ruby
    def auth_failure
      set_flash_message(:notice, "OAuth error: #{params[:message]}")
      redirect_to root_path
    end

    def auth_create
      authorization_hash = request.env['omniauth.auth'].with_indifferent_access
      received_uuid = auth_hash[:extra][:raw_info][:uuid]
      received_email = auth_hash[:extra][:raw_info][:email]

      # use `received_uuid` or `received_email` to find (or create) a user and sign her in
    end
```

There are two possible ways to use `MYDIGIPASS.COM`:
* when someone is signing in with MYDIGIPASS.COM which does not have an account, immediately sign them up
* only allow users you know to sign in with MYDIGIPASS.COM

I will explain those two scenarios in more detail.

> Note: I am assuming you have a `User` model, and that the user has a field called `uuid` that can or will contain the MYDIGIPASS.COM `uuid`.
> You can change these names as you like.

### Scenario 1: unknown users are automatically signed up

On the login page and signup page, we show the MYDIGIPASS.COM button as follows:

    = link_to("connect with mydigipass.com", "#", :class => "dpplus-connect", :"data-client-id" => MDP_CLIENT_ID, :"data-redirect-uri" => MDP_CALLBACK_URL)


Inside your `HomeController` you can use the following `auth_create` implementation:

```ruby
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
```

When a user signs in through MYDIGIPASS.COM, it could be a new user (signing up), or an existing user.
The function `find_or_create_from_auth_hash` handles that for me:

```ruby
    def self.from_auth_hash(auth_hash)
      logger.debug "User.from_auth_hash: auth_hash = #{auth_hash.inspect} "
      received_uuid = auth_hash[:extra][:raw_info][:uuid]
      received_email = auth_hash[:extra][:raw_info][:email]

      user = User.find_by_uuid(received_uuid) || User.find_by_email(received_email)
      user = user.nil? ? create_from_auth_hash(received_uuid, received_email) : prevent_login_with_normal_password(user, received_uuid)
    end
```

I try to find the user, by `uuid` or `email`. If I find the user by `uuid`, she has logged on before with MYDIGIPASS.COM
If I find a matching mail, link the uuid to that user. If I do not find a user, create one with the given `email` and `uuid`.
I also made sure that users can then only login with their MYDIGIPASS.COM and no longer normally, but that is optional of course.

### Scenario 2: only known users can sign in

This scenario is a little more complicated, but offers more protection as well. We want that

* a signed in user can link her MYDIGIPASS.COM account
* a user that we do not know, is not allowed to sign in

So when a user has signed in, conventionally, we want to enable her to link her MYDIGIPASS.COM to her current account.
Normally (depending on your application) there is a profile page, or settings, or properties, where a user can edit her details.
On that page we show a button to link her MYDIGIPASS.COM account as follows:

```haml
-if @user.id == current_user.id
  - if @user.uuid.present?
    %p{:style => 'padding-top: 5px;'}
      Your account is linked with MYDIGIPASS.COM.
  - else
    .connect-with-mydigipass
      %h3
        Connect with your MYDIGIPASS account
      %p
        If you have a MYDIGIPASS.COM account, it is preferred to use that instead to login, so please connect here.
      .mdp-button-spacer{:style => 'padding-top: 5px;'}
        = link_to("connect with mydigipass.com", "#", :class => "dpplus-connect", :"data-client-id" => MDP_CLIENT_ID, :"data-redirect-uri" => MDP_CALLBACK_URL, :"data-style" => 'large', :"data-state" => @user.id)

    %script{:type => 'text/javascript', :src => MDP_JS}
```

The important thing to notice is that the link contains an extra parameter called `data-state`: this can contain any data you wish, and that will be received verbatim in your callback.
We will use this in the callback.

On the login form you show the button as follows:

    = link_to("connect with mydigipass.com", "#", :class => "dpplus-connect", :"data-client-id" => MDP_CLIENT_ID, :"data-redirect-uri" => MDP_CALLBACK_URL)

Inside your `HomeController` add the `auth_create` which will handle both signin in and connecting the account, as follows:

```ruby
  def auth_create
    connect_to_user_id = params[:state]
    auth_hash = request.env['omniauth.auth'].with_indifferent_access
    connected_uuid = auth_hash[:extra][:raw_info][:uuid]

    if connect_to_user_id
      user = User.find(connect_to_user_id)
      user.will_sign_in_with_mydigipass(connected_uuid) if user
    else
      user = User.find_by_uuid(connected_uuid)
    end
    if user
      flash[:notice] = if connect_to_user_id
        "Your account is succesfully linked to your MYDIGIPASS.COM account! From now on you can only sign in using MYDIGIPASS.COM. Thank you!"
      else
        # do we need to show this ??
        "Succesfully logged in using MYDIGPASS.COM."
      end
      @current_user = user
      @user_session = UserSession.create!(user)
    else
      flash[:error] = if connect_to_user_id
        "Something went wrong when trying to connect your user with your MYDIGIPASS.COM account ..."
      else
        "Your MYDIGIPASS.COM is not yet linked to a valid user account. You need to sign in with your exisiting account first, and then link the account (from the profile page). HTH."
      end
    end
    redirect_back_or_default root_path
  end
```

Hope this helps.


## License

Copyright (c) 2012 Nathan Van der Auwera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
