require "sam"
require "../config/initializers/database"
require "../db/migrations/*"
require "file"
require "file_utils"
require "inflector/core_ext"

load_dependencies "jennifer"

Sam.namespace "generate" do
  desc "Generates a controller with actions and corresponding views"
  task "controller" do |_, args|
    controllerName = args[0].as(String).camelcase + "Controller"
    actions = args.raw[1..].map(&.as(String).downcase)
    File.open "./app/controllers/#{controllerName}.cr", "w+" do |file|
      viewsDir = "views/#{args[0].as(String).downcase}"
      FileUtils.mkdir(viewsDir)
      file.puts("class #{controllerName} < ApplicationController")
      actions.each do |action|
        File.write viewsDir + "/#{action}.ecr",
          %<#{action.upcase_first}, find me at #{viewsDir}/#{action}.ecr>
        file.puts "def #{action}"
        file.puts %<render "#{viewsDir}/#{action}.ecr" >
        file.puts "end"
      end
      file.puts("end")
      file.close
      `crystal tool format ./app/controllers/#{controllerName}.cr`
    end
  end

  desc "Generates scaffold"
  task "scaffold" do |task, args|
    scaffoldName = args[0].as(String)
    task.invoke("generate:model", args)
    fields = args.raw[1..].map(&.as(String)).map do |field|
      matchData = /\A([a-zA-Z_]+):([a-z]+)\z/.match(field)
      {fieldName: matchData[1].underscore, type: matchData[2]} if matchData.is_a? Regex::MatchData # return field_name
    end.compact!
    File.write "./app/controllers/#{scaffoldName.camelcase}Controller.cr", <<-CONTROLLER
    class #{scaffoldName.camelcase}Controller < ApplicationController
      def index
        #{scaffoldName.underscore.pluralize} = #{scaffoldName.camelcase}.all
        render "views/#{scaffoldName.underscore}/index.ecr"
      end
      
      def show
        id = params.url["id"]
        #{scaffoldName.underscore} = #{scaffoldName.camelcase}.find!(id)
        render "views/#{scaffoldName.underscore}/show.ecr"
      end


      def new 
        #{scaffoldName.underscore} = #{scaffoldName.camelcase}.new 
        render "views/#{scaffoldName.underscore}/new.ecr"
      end

      def edit
        _id = params.url["id"]
        #{scaffoldName.underscore}  = #{scaffoldName.camelcase}.find!(_id)
        render "views/#{scaffoldName.underscore}/edit.ecr"
      end 

      def create
        if new_user = #{scaffoldName.camelcase}.create!(#{scaffoldName.underscore}_params)
          redirect "/#{scaffoldName.underscore}/\#{new_user.id}"
        else 
          response.status_code = 500
          return "Can not create new #{scaffoldName.camelcase}"
        end
      end       

      def update
        _id = params.url["id"]
        #{scaffoldName.underscore} = #{scaffoldName.camelcase}.find!(_id)
        if #{scaffoldName.underscore}.update(#{scaffoldName.underscore}_params) 
          redirect "/#{scaffoldName.underscore}/\#{_id}"
        else
          response.status_code = 502
          return "Can not update #{scaffoldName.camelcase} with id \#{_id}"
        end
      end

      def destroy
        _id = params.url["id"]
        #{scaffoldName.camelcase}.destroy(_id)
        redirect "/#{scaffoldName.underscore}"
      end 
      
      protected def #{scaffoldName.underscore}_params
        {#{
  fields.map do |field|
      if field
        %(:#{field[:fieldName]} => params.body["#{scaffoldName.underscore}[#{field[:fieldName]}]"])
      end
    end.join(",\n")
}}
      end
    end 
    CONTROLLER
    viewsDir = "./views/#{scaffoldName.underscore}"
    FileUtils.mkdir(viewsDir) rescue nil
    File.write viewsDir + "/index.ecr", <<-INDEX_ECR
      <h1>#{scaffoldName.camelcase.pluralize}</h1>
      <table>
        <thead>
          #{fields.map { |field| %(<th>#{field[:fieldName].camelcase}</th>) if field }.join("\n")}
          <th colspan="3"></th>
        </thead>
        <tbody>
          <% #{scaffoldName.underscore.pluralize}.each do |#{scaffoldName.underscore}| %>
            <tr>
              #{
  fields.map { |field|
      %(<td><%= #{scaffoldName.underscore}.#{field[:fieldName]} %></td>) if field
    }.join("\n")
}
              <td><a href="/#{scaffoldName.underscore}/<%= #{scaffoldName.underscore}.id %>">Show</a></td>
              <td><a href="/#{scaffoldName.underscore}/<%= #{scaffoldName.underscore}.id %>/edit">Edit</a></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    INDEX_ECR

    File.write viewsDir + "/show.ecr", <<-SHOW_ECR
     <h1>#{scaffoldName.camelcase} <%= "\#{#{scaffoldName.underscore}.id}" %></h1>
     <ul>
      #{
  fields.map { |field|
      %(<li><strong>#{field[:fieldName] if field}</strong> : <%= "\#{#{scaffoldName.underscore}.#{field[:fieldName] if field}}" %></li>)
    }.join("\n")
}
     </ul>
    SHOW_ECR

    File.write viewsDir + "/_form.ecr", <<-FORM_PARTIAL
      <div>
        <form action="/#{scaffoldName.underscore}<%= #{scaffoldName.underscore}.new_record? ? "/" : "/\#{#{scaffoldName.underscore}.id}" %>" method="post">
          <% unless #{scaffoldName.underscore}.new_record? %>
            <input type="hidden" name="_method" value="put">
          <% end %>
            <input type="hidden" name="_csrf" value="<%= csrf %>">
          #{
  fields.map do |field|
      if field
        if ["integer", "short", "bigint", "tinyint"].includes? field[:type]
          %(<div>
                    <label for="#{scaffoldName.underscore}_#{field[:fieldName]}">#{field[:fieldName].camelcase}</label>
                    #{%(<input id="#{scaffoldName.underscore}_#{field[:fieldName]}" type="number" name="#{scaffoldName.underscore}[#{field[:fieldName]}]" >)}  
                  </div>)
        elsif ["double", "float", "decimal", "numeric", "string", "char"].includes? field[:type]
          %(<div>
                    <label for="#{scaffoldName.underscore}_#{field[:fieldName]}">#{field[:fieldName].camelcase}</label>
                    #{%(<input id='#{scaffoldName.underscore}_#{field[:fieldName]}' type="text" name="#{scaffoldName.underscore}[#{field[:fieldName]}]">)}  
                  </div>)
        elsif field[:type] == "text"
          %(<div>
                    <label for="#{scaffoldName.underscore}_#{field[:fieldName]}">#{field[:fieldName].camelcase}</label>
                    #{%(<textarea id="#{scaffoldName.underscore}_#{field[:fieldName]}" name="#{scaffoldName.underscore}[#{field[:fieldName]}]"></textarea>)}  
                  </div>)
        elsif field[:type] == "bool"
          %(<div>
            <label for="#{scaffoldName.underscore}_#{field[:fieldName]}">#{field[:fieldName].camelcase}</label>
             #{%(<input id="#{scaffoldName.underscore}_#{field[:fieldName]}" type="checkbox" value="0" name="#{scaffoldName.underscore}[#{field[:fieldName]}]">)}  
                  </div>)
        elsif ["timestamp", "date_time"].includes? field[:type]
          %(<div>
                    <label for="#{scaffoldName.underscore}_#{field[:fieldName]}">#{field[:fieldName].camelcase}</label>
                    #{%(<input id="#{scaffoldName.underscore}_#{field[:fieldName]}" type="datetime-local" name="#{scaffoldName.underscore}[#{field[:fieldName]}]">)}  
                  </div>)
        elsif field[:type] == "reference"
          %(<div>
                    <label for="#{scaffoldName.underscore}_#{field[:fieldName]}_id">#{field[:fieldName].camelcase}</label>
                    #{%(<input id="#{scaffoldName.underscore}_#{field[:fieldName]}_id" type="text" name="#{scaffoldName.underscore}[#{field[:fieldName]}_id]">)}  
                  </div>)
        end
      end
    end.join("\n")
}
          <div>
            <input type="submit" value="Submit" >
          </div>
        </form>
      </div>
      FORM_PARTIAL

    File.write viewsDir + "/new.ecr", <<-NEW_ECR
     <h1>New #{scaffoldName.camelcase}</h1>
     <%= render "#{viewsDir}/_form.ecr" %>

   NEW_ECR

    File.write viewsDir + "/edit.ecr", <<-EDIT_ECR
      <h1>Edit #{scaffoldName.camelcase}</h1>
      <%= render "#{viewsDir}/_form.ecr" %>
    EDIT_ECR

    `crystal tool format ./app/controllers/#{scaffoldName.camelcase}Controller.cr`
  end
end

Sam.namespace "destroy" do
  desc "Destroy a scaffold and its depends"
  task "scaffold" do |task, args|
    scaffoldName = args[0].as(String)
    task.invoke("destroy:model", scaffoldName.downcase)
    task.invoke("destroy:controller", scaffoldName)
  end

  desc "Destroys a controller with its own views"
  task "controller" do |_, args|
    controllerName = args[0].as(String)
    FileUtils.rm("./app/controllers/#{controllerName.camelcase}Controller.cr")
    FileUtils.rm_rf("./views/#{controllerName}/")
  end

  desc "Destroys a model and its migrations"
  task "model" do |_, args|
    modelName = args[0].as(String)
    FileUtils.rm("./app/models/#{modelName.downcase}.cr")
    FileUtils.rm_rf(Dir["./db/migrations/*"].select!(&.includes?(modelName.pluralize.downcase)))
  end

  desc "Destroy a migration"
  task "migration" do |_, args|
    migration = args[0].as(String).underscore
    FileUtils.rm_rf(Dir["./db/migrations/*"].select!(&.includes?(migration)))
  end
end
Sam.help
