require 'net/https'
require 'uri'

module Synchrolog
  module Client
    class HTTPS
      def initialize(api_key, opts)
        @api_key = api_key
        @host = opts['host']
      end

      def write(message)
        return unless message[:anonymous_id]
        json_headers = {'Authorization' => "Basic #{@api_key}", 'Content-Type' =>'application/json'}
        uri = URI.parse(@host)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
      	http.verify_mode = OpenSSL::SSL::VERIFY_NONE      
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
