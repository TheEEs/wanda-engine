ENV["APP_ENV"] = "test"
require "spec"
require "kemal"
require "wanda-csrf"
require "../src/configurations"
require "../src/routing"
require "../src/viewHelpers"
require "../src/application_controller"
require "./models/*"

module Wanda::ViewHelpers
  Wanda.generate_views_helper "./spec/view_helpers/LinkTo.ecr"
end

class UserController < Wanda::ApplicationController
  use_layout false

  def index
    "user_page"
  end

  def show
    _userId = params.url["id"]
    user = User.find! _userId
    user.name
  end

  def create
    userName = params.body["name"]
    userGender = params.body["gender"] == "male"
    User.create! name: userName, gender: userGender
    "user created!"
  end

  def update
    _userId = params.url["id"]
    userName = params.body["name"]
    userGender = params.body["gender"] == "male"
    user = User.all.last
    user.update name: userName, gender: userGender if user
    "user updated"
  end

  def destroy
    _userId = params.url["id"]
    User.all.last.try &.destroy
    redirect "/user"
  end

  def raise_csrf
  end

  def simulate_put
    "put method"
  end
end

Wanda.resources_for "user", except: [:new, :edit, :show]
Wanda.post "/raise_csrf", UserController, :raise_csrf
Wanda.put "/simulate_put", UserController, :simulate_put
Wanda::Configs.bundled_with_turbolinks false
add_handler CSRF.new(
  allowed_methods: ["GET", "PUT", "POST", "DELETE"],
  allowed_routes: [
    "/user",
    "/user/1",
  ]
)
spawn do
  Wanda.run
end

Fiber.yield
