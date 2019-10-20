ENV["APP_ENV"] = "test"
require "spec"
require "kemal"
require "wanda-csrf"
require "../src/configurations"
require "../src/routing"
require "../src/viewHelpers"
require "../src/application_controller"
require "../src/socket_connection"
require "./models/*"

CHANNEL = Channel(String).new

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

class TestWsConnection < Wanda::WebSocketConnection
  def authorize
    true
  end

  def connected
    stream_from "/chat/channel"
    puts "Hello WebSocket, I'm Connected"
    # Wanda::SOCKET_POOLS.add_connection_to_the_pool(streamed_from, self)
    # should rise an exception
  end

  def received(message : String)
    broadcast "send back:#{message}"
  end

  def disconnected
    puts "Goodbye, I'm going to die"
  end
end

Wanda.resources_for "user", except: [:new, :edit, :show]
Wanda.post "/raise_csrf", UserController, :raise_csrf
Wanda.put "/simulate_put", UserController, :simulate_put
Wanda.web_socket_mount "/chat", TestWsConnection

Wanda::Configs.bundled_with_turbolinks false

Wanda::Configs.cache_engine :memory

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
