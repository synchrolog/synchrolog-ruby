require 'synchrolog/client/https'
require 'synchrolog/client/http'

module Synchrolog
  module Client
    def self.new(api_key, opts)
      opts['host'] = opts.key?('host') ? opts['host'] : 'https://input.synchrolog.com/v1/track-backend'
      if /^https:\/\//.match(opts['host'])
        Synchrolog::Client::HTTPS.new(api_key, opts)
      else
        Synchrolog::Client::HTTP.new(api_key, opts)
      end
    end
  end
end
