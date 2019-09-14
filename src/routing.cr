module Wanda
  @@redirected : (String?) = nil
  @@namespaces = [] of String

  def self.redirected
    @@redirected
  end

  def self.redirected=(location : String?)
    @@redirected = location
  end

  def self.namespace(namespace)
    @@namespaces << namespace
    with Wanda yield
    @@namespaces.pop
  end

  def self.namespaces
    return "" if @@namespaces.empty?
    "/" + @@namespaces.join("/")
  end

  def self.route
    with Wanda yield
  end
end

module Wanda
  macro root(controller, action)
    ::get("#{Wanda.namespaces}" + "/") do |env| 
      Wanda.cache_engine.fetch(env.request.path) do 
        c = {{controller}}.new env
        buffered_result = c.{{action.id}}
        redirected = Wanda.redirected
        if redirected
          Wanda.redirected = nil
          redirected
        else
          buffered_result
        end
      end
    end
  end

  macro generate_routes
        {% for verb in {:get, :put, :post, :delete} %}
            macro {{verb.id}}(route, controller, action = {{verb}})
            ::{{verb.id}}("#{Wanda.namespaces}" + \{{route}}) do |env|  
              {% if verb == :get %}
              Wanda.cache_engine.fetch(env.request.path) do 
                c = \{{controller}}.new env
                buffered_result = c.\{{action.id}}
                redirected = Wanda.redirected
                if redirected
                    Wanda.redirected = nil
                    redirected
                else
                    buffered_result
                end
              end
              {% else %}
                c = \{{controller}}.new env
                buffered_result = c.\{{action.id}}
                redirected = Wanda.redirected
                if redirected
                    Wanda.redirected = nil
                    redirected
                else
                    buffered_result
                end
              {% end %}
            end
        end
        {% end %}
    end

  generate_routes
end

module Wanda
  macro resources_for(resource_name, only = [:index, :show, :new, :edit, :create, :update, :destroy], except = [] of Symbol)
    {% only = only.select do |verb|
         !(except.includes? verb)
       end %}  
    {% resource_name = resource_name.underscore %}
      {% for method in only %}
        {% if method == :index %}
          Wanda.get {{ "/" + resource_name }} , {{resource_name.id.camelcase}}Controller, :index
        {% elsif method == :new %}
          Wanda.get {{ "/" + resource_name + "/new" }} , {{resource_name.id.camelcase}}Controller, :new
        {% elsif method == :edit %}
          Wanda.get {{ "/" + resource_name + "/:id/edit" }} , {{resource_name.id.camelcase}}Controller, :edit
        {% elsif method == :show %}
          Wanda.get {{ "/" + resource_name + "/:id" }} , {{resource_name.id.camelcase}}Controller, :show
        {% elsif method == :create %}
          Wanda.post {{ "/" + resource_name }} , {{resource_name.id.camelcase}}Controller, :create
        {% elsif method == :update %}
          Wanda.put {{ "/" + resource_name + "/:id" }} , {{resource_name.id.camelcase}}Controller, :update
        {% elsif method == :destroy %}
          Wanda.delete {{ "/" + resource_name + "/:id" }} , {{resource_name.id.camelcase}}Controller, :destroy
        {% end %}
      {% end %}
    end
end
