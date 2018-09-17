require 'synchrolog/client/https'
require 'synchrolog/client/http'

module Synchrolog
  module Client
    def self.new(api_key, **args)
      args[:host] ||= 'https://input.synchrolog.com'
      if /^https:\/\//.match(args[:host])
        Synchrolog::Client::HTTPS.new(api_key, args)
      else
        Synchrolog::Client::HTTP.new(api_key, args)
      end
    end
  end
end
