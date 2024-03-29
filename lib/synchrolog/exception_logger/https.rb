require 'net/https'
require 'uri'

module Synchrolog
  module ExceptionLogger
    class HTTPS
      def initialize(api_key, args = {})
        @api_key = api_key
        @host = args[:host]
      end

      def capture(response, exception, env, clip_id)
        return unless clip_id
        json_headers = {'Authorization' => "Basic #{@api_key}", 'Content-Type' =>'application/json'}
        uri = URI.parse("#{@host}/v1/track-backend-error")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
      	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.post(uri.path, body(response, exception, env, clip_id).to_json, json_headers)
      end

      def body(response, exception, env, clip_id)
        status, headers, body = *response
        error = exception.backtrace[0].split(':')
        return {
          event_type: 'error',
          timestamp: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
          clip_id: clip_id,
          source: 'backend',
          api_key: @api_key,
          error: {
            status: status.to_s,
            description: exception.to_s,
            backtrace: exception.backtrace.join("\n"),
            ip_address: env['REMOTE_ADDR'],
            user_agent: env['HTTP_USER_AGENT'],
            file_name: file_name = error[0],
            file: File.read(error[0]),
            line_number: error[1].to_i
          }
        }
      end
    end
  end
end
