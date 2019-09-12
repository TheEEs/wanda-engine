require "ecr"

module Wanda
  macro generate_views_helper(path)
    {%
      files = `ls #{path.id}`.strip.lines
      fileNamesWithoutExtension = files.map do |fname|
        fileNameSplit = fname.split("/")
        result = fileNameSplit.last.gsub(/\A(([A-Za-z0-9_]+)\/)+/, "")
        result.gsub(/\.ecr\z/, "")
      end
    %}
    {% for name in fileNamesWithoutExtension %}
       macro {{name.id.underscore}}(**args)
           \{% for key in args.keys %}
               \{{key}} = \{{args[key]}}
           \{% end %}
           ECR.render ("app/view_helpers/" + {{name}} +".ecr")
       end
    {% end %}
  end

  def run
    Kemal.run
  end
end
