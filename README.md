Rack::UTM
================

Rack::UTM is a rack middleware that extracts information about the utm tracking codes. Specifically, it looks up for specific parameter (<code>utm-*</code> by default) in the request. If found, it persists utm tag values in a cookie for later use.

Common Scenario
---------------

UTM links tracking is very common task if you want to promote your online business. This middleware helps you to do that.

1. Use UTM Link to promote your business like <code>http://yoursite.org?utm_source=ABC123....</code>.
2. A user clicks through the link and lands on your site.
3. Rack::Utm middleware finds <code>utm_*</code> parameters in the request, extracts them and saves it in a cookie
4. User signs up (now or later) and you know the utm params the user has assigned
5. PROFIT!

Installation
------------

Piece a cake:

    gem install rack-utm


Rails 3 Example Usage
---------------------

Add the middleware to your application stack:

    # Rails 3 App - in config/application.rb
    class Application < Rails::Application
      ...
      config.middleware.use Rack::Utm
      ...
    end
    
    # Rails 2 App - in config/environment.rb
    Rails::Initializer.run do |config|
      ...
      config.middleware.use "Rack::Utm"
      ...
    end

Now you can check any request to see who came to your site via an affiliated link and use this information in your application. Affiliate tag is saved in the cookie and will come into play if user returns to your site later.

    class ExampleController < ApplicationController
      def index
        str = if request.env['utm.source']
          "Hallo, user! You've been referred here by #{request.env['utm.source']}, #{request.env['utm.medium']}, ...."
        else
          "We're glad you found us on your own!"
        end
        
        render :text => str
      end
    end


Customization
-------------

By default cookie is set for 30 days, you can extend time to live with <code>:ttl</code> option (default is 30 days).

    #Rails 3 in config/application.rb
    class Application < Rails::Application
      ...
      config.middleware.use Rack::Affiliates, {:ttl => 3.months}
      ...
    end

The <code>:domain</code> option allows to customize cookie domain. 

    #Rails 3 in config/application.rb
    class Application < Rails::Application
      ...
      config.middleware.use Rack::Affiliates, :domain => '.example.org'
      ...
    end

Middleware will set cookie on <code>.example.org</code> so it's accessible on <code>www.example.org</code>, <code>app.example.org</code> etc.

The <code>:overwrite</code> option allows to set whether to overwrite the existing utm tag previously stored in cookies. By default it is set to `true`.

Credits
=======

Thanks goes to Rack::Referrals (https://github.com/deviantech/rack-referrals) and Rack::Affiliates (https://github.com/alexlevin/rack-affiliates) for the inspiration.

