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
        msg = message.dup
        clip_id_match = msg.match(/\[synchrolog_clip_id:(\S*)\]/)
        clip_id = clip_id_match.try(:[], 1)
        msg.slice!(clip_id_match.begin(0)..clip_id_match[0].length) if clip_id
        { type: severity, timestamp: timestamp.utc.iso8601(3), message: msg, clip_id: clip_id }
      end
    end
  end
end
