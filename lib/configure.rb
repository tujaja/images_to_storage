require 'fileutils'

raw_config = File.read(RAILS_ROOT + "/config/images_storage.yml")
IMG_CONFIG = YAML.load(raw_config)[RAILS_ENV]

# if storage directory doesn't exist, then create it.
path = "#{IMG_CONFIG['storage_path']}"
unless File.exists? path
  FileUtils.mkdir path
  p "#{path} directory is created."
end
