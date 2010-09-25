# Install hook code here
require File.expand_path(
  File.join(File.dirname(__FILE__), '../../../config/environment')
)

FileUtils.cp  "./images_storage.yml", "#{RAILS_ROOT}/config"
