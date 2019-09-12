require "kemal"
require "wanda-csrf"
require "./configurations"
require "./routing"
require "./viewHelpers"
require "./application_controller"

module Wanda::ViewHelpers
  Wanda.generate_views_helper "./app/view_helpers/*.ecr"
end
