require "ecr"

macro generate_views_helper
 {%
   files = `ls ./app/view_helpers/*.ecr`.strip.lines # split(/\n|\w/, remove_empty: true)
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

module Wanda
  module ViewHelpers
    generate_views_helper
  end

  def run
    Kemal.run
  end
end
