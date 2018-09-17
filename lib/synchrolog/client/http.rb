require 'net/http'
require 'uri'

module Synchrolog
  module Client
    class HTTP
      def initialize(api_key, **args)
        @api_key = api_key
        @host = args[:host]
      end

      def write(message)
        return unless message[:anonymous_id]
        json_headers = {'Authorization' => "Basic #{@api_key}", 'Content-Type' =>'application/json'}
        uri = URI.parse("#{@host}/v1/track-backend")
        http = Net::HTTP.new(uri.host, uri.port)
        http.post(uri.path, body(message).to_json, json_headers)
      end

      def body(message)
        {
          event_type: 'track', 
          timestamp: message[:timestamp],
          anonymous_id: message[:anonymous_id],
          user_id: message[:user_id],
          source: 'backend',
          api_key: @api_key,
          log: message
        }
      end

      def close
        nil
      end
    end
  end
end
