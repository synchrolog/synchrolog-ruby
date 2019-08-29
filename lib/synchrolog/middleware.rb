require 'securerandom'
require 'json'

module Synchrolog
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      request = ActionDispatch::Request.new(env)
      if request.original_fullpath == "/synchrolog-time"
        [ 200, {'Content-Type' => 'application/json'}, [{ time: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%3NZ") }.to_json] ]
      else
        if request.cookie_jar['synchrolog_anonymous_id'].nil?
          request.cookie_jar['synchrolog_anonymous_id'] = SecureRandom.hex
        end
        anonymous_id = request.cookie_jar['synchrolog_anonymous_id']
        user_id = request.cookie_jar['synchrolog_user_id']
        SYNCHROLOG.logger.tagged("synchrolog_anonymous_id:#{anonymous_id}", "synchrolog_user_id:#{user_id}") do
          begin
            response = @app.call(env)
          rescue Exception => exception
            SYNCHROLOG.exception_logger.capture(response, exception, env, anonymous_id, user_id)
            raise
          end
          exception = env['rack.exception'] || env['action_dispatch.exception']
          SYNCHROLOG.exception_logger.capture(response, exception, env, anonymous_id, user_id) if exception
          response
        end
      end
    end
  end
end
