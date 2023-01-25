require 'synchrolog/logger/https'
require 'synchrolog/logger/http'

module Synchrolog
  module Logger
    def self.new(api_key, args = {})
      args[:host] ||= 'https://input.synchrolog.com'
      if /^https:\/\//.match(args[:host])
        Synchrolog::Logger::HTTPS.new(api_key, args)
      else
        Synchrolog::Logger::HTTP.new(api_key, args)
      end
    end
  end
end
