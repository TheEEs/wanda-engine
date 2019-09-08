require "http"

module Wanda
  class MethodOverrider < Kemal::Handler
    def call(env)
      if env.request.method == "POST"
        if env.params.body["_method"]?.to_s.downcase == "put"
          env.request.method = "PUT"
          route_lookup = \
             Kemal::RouteHandler::INSTANCE.lookup_route(env.request.method.as(String), env.request.path)
          url_params = Kemal::ParamParser.new(env.request, route_lookup.params).url
          url_params.keys.each do |key|
            env.params.url[key] = url_params[key]
          end
        elsif env.params.body["_method"]?.to_s.downcase == "delete"
          env.request.method = "DELETE"
        end
      end
      call_next(env)
    end
  end
end
