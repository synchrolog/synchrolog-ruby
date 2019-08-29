require 'synchrolog/version'
require 'synchrolog/logger'
require 'synchrolog/exception_logger'
require 'synchrolog/middleware'

require 'active_support/logger'
require 'active_support/tagged_logging'

module Synchrolog
  class Client
    def initialize(api_key, opts={})
      @api_key = api_key
      @opts = opts
    end

    def logger
      @logger ||= initialize_logger
    end

    def exception_logger
      @exception_logger ||= initialize_exception_logger
    end

    private

    def initialize_logger
      client = Synchrolog::Logger.new(@api_key, @opts)
      logger = ActiveSupport::Logger.new(client)
      logger.formatter = SynchrologFormatter.new
      ActiveSupport::TaggedLogging.new(logger)
    end

    def initialize_exception_logger
      Synchrolog::ExceptionLogger.new(@api_key, @opts)
    end

    class SynchrologFormatter < ActiveSupport::Logger::SimpleFormatter
      def call(severity, timestamp, progname, message)
        anonymous_id_match = message.match(/\[synchrolog_anonymous_id:(\S*)\]/)
        anonymous_id = anonymous_id_match.try(:[], 1)
        msg = message.dup
        msg.slice!(anonymous_id_match.begin(0)..anonymous_id_match[0].length) if anonymous_id
        user_id_match = msg.match(/\[synchrolog_user_id:(\S*)\]/)
        user_id = user_id_match.try(:[], 1)
        msg.slice!(user_id_match.begin(0)..user_id_match[0].length) if user_id
        { type: severity, timestamp: timestamp.utc.iso8601(3), message: msg, anonymous_id: anonymous_id, user_id: user_id }
      end
    end
  end
end
