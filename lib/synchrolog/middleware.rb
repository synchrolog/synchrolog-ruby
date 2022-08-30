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
      elsif request.cookies['synchrolog_clip_id'].nil?
        @app.call(env)
      else
        clip_id = request.cookies['synchrolog_clip_id']
        SYNCHROLOG.logger.tagged("synchrolog_clip_id:#{clip_id}") do
          begin
            response = @app.call(env)
          rescue Exception => exception
            SYNCHROLOG.exception_logger.capture(response, exception, env, clip_id)
            raise
          end
          exception = env['rack.exception'] || env['action_dispatch.exception']
          SYNCHROLOG.exception_logger.capture(response, exception, env, clip_id) if exception
          response
        end
      end
    end
  end
end
