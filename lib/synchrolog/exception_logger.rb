require 'synchrolog/exception_logger/https'
require 'synchrolog/exception_logger/http'

module Synchrolog
  module ExceptionLogger
    def self.new(api_key, args = {})
      args[:host] ||= 'https://input.synchrolog.com'
      if /^https:\/\//.match(args[:host])
        Synchrolog::ExceptionLogger::HTTPS.new(api_key, args)
      else
        Synchrolog::ExceptionLogger::HTTP.new(api_key, args)
      end
    end
  end
end
