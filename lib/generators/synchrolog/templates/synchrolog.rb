SYNCHROLOG = Synchrolog::Client.new('YOUR_API_KEY') 
Rails.logger.extend(ActiveSupport::Logger.broadcast(SYNCHROLOG.logger))
