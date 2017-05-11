module Rack
  #
  # Rack Middleware for extracting information from the request params and cookies.
  # It populates +env['affiliate.tag']+, # +env['affiliate.from']+ and
  # +env['affiliate.time'] if it detects a request came from an affiliated link 
  #
  class Utm

    COOKIE_SOURCE   = "u_source"
    COOKIE_MEDIUM   = "u_medium"
    COOKIE_TERM     = "u_term"
    COOKIE_CONTENT  = "u_content"
    COOKIE_CAMPAIGN = "u_campaign"
    
    COOKIE_FROM     = "u_from"
    COOKIE_TIME     = "u_time"
    COOKIE_LP       = "u_lp"
    
    def initialize(app, opts = {})
      @app = app
      @key_param = "utm_source"
      @cookie_ttl = opts[:ttl] || 60*60*24*30  # 30 days
      @cookie_domain = opts[:domain] || nil
      @allow_overwrite = opts[:overwrite].nil? ? true : opts[:overwrite] 
    end

    def call(env)
      req = Rack::Request.new(env)

      params_tag = req.params[@key_param]
      cookie_tag = req.cookies[COOKIE_SOURCE]

      params_from_tag = req.env["HTTP_REFERER"]
      cookie_from_tag = req.cookies[COOKIE_FROM]

      if cookie_tag || cookie_from_tag
        source, medium, term, content, campaign, from, time, lp = cookie_info(req)
      end

      if (params_tag && params_tag != cookie_tag) ||
        (params_from_tag &&  params_from_tag != cookie_from_tag)

        if source || from
          if @allow_overwrite
            source, medium, term, content, campaign, from, time, lp = params_info(req)
          end
        else
          source, medium, term, content, campaign, from, time, lp = params_info(req)
        end
      end

      if source || from
        env["utm.source"] = source
        env['utm.medium'] = medium
        env['utm.term'] = term
        env['utm.content'] = content
        env['utm.campaign'] = campaign

        env['utm.from'] = from
        env['utm.time'] = time
        env['utm.lp'] = lp
      end

      status, headers, body = @app.call(env)

      if source != cookie_tag
        bake_cookies(headers, source, medium, term, content, campaign, from, time, lp)
      end

      [status, headers, body]
    end

    def utm_info(req)
      params_info(req) || cookie_info(req) 
    end

    def params_info(req)
      [
          req.params["utm_source"],
          req.params["utm_medium"],
          req.params["utm_term"],
          req.params["utm_content"],
          req.params["utm_campaign"],
          req.env["HTTP_REFERER"],
          Time.now.to_i,
          req.path
      ]
    end

    def cookie_info(req)
      [
        req.cookies[COOKIE_SOURCE],
        req.cookies[COOKIE_MEDIUM],
        req.cookies[COOKIE_TERM],
        req.cookies[COOKIE_CONTENT],
        req.cookies[COOKIE_CAMPAIGN],
        
        req.cookies[COOKIE_FROM],
        req.cookies[COOKIE_TIME],
        req.cookies[COOKIE_LP]

      ]
    end

    protected
    def bake_cookies(headers, source, medium, term, content, campaign, from, time, lp)
      expires = Time.now + @cookie_ttl
      { COOKIE_SOURCE => source,
        COOKIE_MEDIUM => medium,
        COOKIE_TERM => term,
        COOKIE_CONTENT => content,
        COOKIE_CAMPAIGN => campaign,
        COOKIE_FROM => from,
        COOKIE_TIME => time,
        COOKIE_LP => lp
      }.each do |key, value|
          cookie_hash = {:value => value,
                         :expires => expires,
                         :path => "/"}
          cookie_hash[:domain] = @cookie_domain if @cookie_domain
          Rack::Utils.set_cookie_header!(headers, key, cookie_hash)
      end 
    end
  end
end
