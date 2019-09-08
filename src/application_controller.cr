require "ecr"
require "json"

class Wanda::ApplicationController
  property env : HTTP::Server::Context
  @@useLayout = true

  def self.use_layout(@@useLayout = true)
  end

  def initialize(@env : HTTP::Server::Context)
  end

  macro inherited
        def get 
        end
        def post
        end
        def update
        end
        def delete
        end
    end

  def request
    self.env.request
  end

  def response
    self.env.response
  end

  def params
    self.env.params
  end

  def session
    self.env.session
  end

  def csrf
    self.session.string("csrf")
  end

  def redirect(location : String)
    self.response.headers["Turbolinks-Location"] = location
    if Wanda::Configs.bundled_with_turbolinks && \
          !{"GET", "HEAD", "OPTIONS", "TRACE"}.includes?(self.request.method.upcase)
      Wanda.redirected = location
    else
      self.env.redirect location
    end
  end

  macro render(template, withLayout = true)
        if @@useLayout && {{withLayout}}
            _yield = ECR.render {{template}}
            ECR.render "views/layout/layout.ecr" 
        else
            ECR.render {{template}}
        end
    end
end
