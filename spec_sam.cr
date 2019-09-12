require "sam"
require "jennifer"
require "jennifer_sqlite3_adapter"
require "./spec/db/migrations/*"
ENV["APP_ENV"] = "test"
Jennifer::Config.read("#{`pwd`.strip}/spec/database.yml", "test")
Jennifer::Config.configure do |conf|
  conf.model_files_path = "spec/models"
  conf.migration_files_path = "spec/db/migrations"
  conf.pool_size = 3
  conf.logger.level = Logger::DEBUG
end

load_dependencies "jennifer"

Sam.help
