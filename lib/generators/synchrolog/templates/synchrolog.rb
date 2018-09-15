SYNCHROLOG = Synchrolog.new('YOUR_API_KEY') 
Rails.logger.extend(ActiveSupport::Logger.broadcast(SYNCHROLOG))