require "./method_overrider"
require "jennifer"
require "jennifer_sqlite3_adapter"

module Wanda::Configs
  CONFIGs = {
    :bundled_js_files        => [] of (String),
    :bundled_with_turbolinks => true,
  }

  def self.server_port(port : Int32)
    Kemal::Config::INSTANCE.port = port
  end

  def self.include_js_files
    yield Configs::CONFIGs[:bundled_js_files].as(Array(String))
  end

  def self.bundled_with_turbolinks
    Configs::CONFIGs[:bundled_with_turbolinks]
  end

  def self.bundled_with_turbolinks(is_bundled : Bool)
    Configs::CONFIGs[:bundled_with_turbolinks] = is_bundled
  end

  def self.js_include_tags(mode = "development")
    Configs::CONFIGs[:bundled_js_files].as(Array(String)).map { |file_name|
      "<script src='#{mode == "development" ? "http://localhost:8080" : ""}/#{file_name}'></script>"
    }.join('\n')
  end
end

module Wanda
  def self.configs
    with Wanda::Configs yield
  end

  def self.run
    Kemal.run
  end
end

Kemal::Session.config do |config|
  config.secret = "tranbadat_deptry_thanThanh"
end

Jennifer::Config.read("#{`pwd`.strip}/config/database.yml", ENV["APP_ENV"]? || "development")
Jennifer::Config.from_uri(ENV["DATABASE_URI"]) if ENV.has_key?("DATABASE_URI")

Jennifer::Config.configure do |conf|
  conf.model_files_path = "app/models"
  conf.pool_size = 3
  conf.logger.level = Logger::DEBUG
end

public_folder "../js/dist"
Kemal::Config::INSTANCE.add_handler Wanda::MethodOverrider.new
Kemal::Config::INSTANCE.add_handler CSRF.new(
  allowed_methods: ["GET", "HEAD", "OPTIONS", "TRACE"],
  parameter_name: "_csrf"
)
