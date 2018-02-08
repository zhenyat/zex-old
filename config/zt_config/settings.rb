################################################################################
#   settings.rb:  Sets Constants and other Parameters for the run
#                 Called by: zt_load_config.rb
#   Relative path MUST BE applied to public/images, otherwise - sprockets error
#
#   11.10.2016  ZT  Inherited from BKC 95km
#   09.11.2016  MULTILINGUAL added
#   30.08.2017  'access_restricted' key is added
################################################################################

##### Debugging   #####
ZT_DEBUG = ZT_CONFIG['debug']['status']

if ZT_CONFIG['debug']['path'].nil? || ZT_CONFIG['debug']['path'].empty?
  ZT_LOG_FILE = nil
else
  ZT_LOG_FILE = "#{Rails.root}/#{ZT_CONFIG['debug']['path']}"
end

# Debug Logging: Create a log-file
if ZT_DEBUG == true && !ZT_LOG_FILE.nil?
  File.open(ZT_LOG_FILE, 'w') { |file| file.puts "Starting debug log..."}
end

##### Mail  #####
MAIL_BCC = ZT_CONFIG['mail']['bcc']

# Access control
ACCESS_RESTRICTED = ZT_CONFIG['access_restricted']

##### Time Slot for candles  #####
PERIOD    = eval ZT_CONFIG['period'] 
TIME_SLOT = eval ZT_CONFIG['time_slot']
