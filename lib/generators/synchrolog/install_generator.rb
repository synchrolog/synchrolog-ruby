require 'rails/generators/base'

module Synchrolog
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      desc "Creates a Synchrolog initializer."

      def copy_initializer
        template "synchrolog.rb", "config/initializers/synchrolog.rb"
        application "config.middleware.insert_after 'Rack::Runtime', 'Synchrolog::Middleware'"
      end      
    end
  end
end