# Uninstall hook code here

require File.expand_path(
  File.join(File.dirname(__FILE__), '../../../config/environment')
)

FileUtils.rm  "#{RAILS_ROOT}/config/images_storage.yml"
