# ImagesToStorage

require 'pathname'
require 'RMagick'
require 'base64'

module ImagesToStorage
  def self.included(model)
    model.extend ClassMethods
    model.class_eval do
      include InstanceMethods
    end

    model.before_update :delete_old_from_storage
    model.before_save :make_filename
    model.after_save :save_to_storage

  end

  module ClassMethods
    class_eval <<-STUFF
      def storage_path
        path = "#{IMG_CONFIG['storage_path']}/"
      end
    STUFF
  end

  module InstanceMethods
    def uploaded_file=(file)
      return if file == ""

      convert_to_image file.read
    end

    protected

      def convert_to_image(file_data)
        data = Base64.encode64(file_data)
        @image = Magick::Image::read_inline(data).first
      end

      def save_to_storage
        # todo
        # configで指定した形式で保存

        icon_path =  "#{Image.storage_path}#{self.filename.to_s}.icon.jpg"
        thumb_path = "#{Image.storage_path}#{self.filename.to_s}.thumb.jpg"

        icon_jpg_img = convert_to_jpg(@image.clone, 50)
        thumb_jpg_img = convert_to_jpg(@image.clone, 100)

        File.open(icon_path, "wb")  {|f| f.write icon_jpg_img }
        File.open(thumb_path, "wb") {|f| f.write thumb_jpg_img }

        @image = nil
      end

      def make_filename
        @old_filename = self.filename
        self.filename = Digest::MD5.hexdigest("--#{Time.now}--")
      end

      def convert_to_jpg(image, size)
        geometry_string = (1 > (image.rows.to_f / image.columns.to_f)) ? "x#{size}" : "#{size}"
        image = image.change_geometry(geometry_string) do |cols, rows, img|
          img.resize!(cols, rows)
        end
        image = image.crop(Magick::CenterGravity, size, size)
        image.profile!('*', nil)
        return image.to_blob { self.format='JPG'; self.quality = 60 }
      end

      def delete_old_from_storage
        FileUtils.rm( Dir.glob("#{Image.storage_path}#{@old_filename}.*.jpg") )
      end

  end
end
