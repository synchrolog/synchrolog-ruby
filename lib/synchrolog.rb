require 'synchrolog/version'
require 'synchrolog/client'
require 'synchrolog/middleware'

require 'active_support/logger'
require 'active_support/tagged_logging'
 
module Synchrolog
  def self.new(api_key, opts={})
    client = Synchrolog::Client.new(api_key, opts)
    logger = Logger.new(client)
    logger.formatter = SynchrologFormatter.new
    ActiveSupport::TaggedLogging.new(logger)
  end

  class SynchrologFormatter < ActiveSupport::Logger::SimpleFormatter
    def call(severity, timestamp, progname, message)
      anonymous_id_match = message.match(/\[synchrolog_anonymous_id:(\S*)\]/)
      anonymous_id = anonymous_id_match.try(:[], 1)
      message.slice!(anonymous_id_match.begin(0)..anonymous_id_match[0].length) if anonymous_id

      user_id_match = message.match(/\[synchrolog_user_id:(\S*)\]/)
      user_id = user_id_match.try(:[], 1)
      message.slice!(user_id_match.begin(0)..user_id_match[0].length) if user_id
      { type: severity, timestamp: timestamp.utc.iso8601(3), message: message, anonymous_id: anonymous_id, user_id: user_id }
    end
  end
end