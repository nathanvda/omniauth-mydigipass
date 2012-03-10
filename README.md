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



## License

Copyright (c) 2012 Nathan Van der Auwera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
