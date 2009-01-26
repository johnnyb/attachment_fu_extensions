module AttachmentFuExtensions
  module ClassMethods
    # Define an attachment using the Attachment class
    def self.has_one_attachment(relationship)
      has_one relationship, :as => :attachable, :class_name => "Attachment", :conditions => "relationship = '#{relationship}'", :dependent => :destroy
      define_method("attach_#{relationship}") do |file_field|
        #FIXME - find a way to delete the old file!!!!

        unless file_field.nil?
          if file_field.size > 0

            new_relationship_obj = self.send("create_#{relationship}", :uploaded_data => file_field, :relationship => relationship.to_s)

            return new_relationship_obj
          end
        end
      end
    end

    # Define a set of attachments using the Attachment class
    def self.has_many_attachments(relationship)
      has_many relationship, :as => :attachable, :class_name => "Attachment", :conditions => "relationship = '#{relationship}'", :dependent => :destroy, :order => "attachments.position, attachments.id"
      define_method("add_#{relationship}_attachment") do |file_field, position|
        if file_field.size > 0
          attach_info = {:uploaded_data => file_field, :relationship => relationship.to_s}
          unless position.nil?
            attach_info[:position] = position
          end
          new_relationship_obj = self.send(relationship).create!(attach_info)
        end
      end
      define_method("create_#{relationship}_attachment") do |atts|
        if atts[:uploaded_data] && atts[:uploaded_data].size > 0
          return self.send(relationship).create!(atts.merge({:relationship => relationship.to_s}))
        end
      end
      define_method("update_#{relationship}_attachment") do |id, atts|
        unless atts[:uploaded_data] && atts[:uploaded_data].size > 0
          atts.delete(:uploaded_data)
        end
        self.send(relationship).find(id).update_attributes!(atts)
      end
      define_method("replace_#{relationship}_attachment") do |file_field, position|
        if position.nil?
          raise ArgumentError.new("Argument missing: position")
        end
        position = position.to_i

        if file_field.size > 0
          old_attachment = self.send(relationship)[position]
          unless old_attachment.nil?
            position = old_attachment.position
            old_attachment.destroy
          end
          attach_info = {:uploaded_data => file_field, :relationship => relationship.to_s, :position => position}
          new_relationship_obj = self.send(relationship).create!(attach_info)
        end

      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end

module AttachmentFuExtensionsHelper
  #Options for autosize
  # :width => force an exact width
  # :height => force an exact height
  # :maxwidth => like it sounds
  # :maxheight => like it sounds, too
  #
  #Runs image through Rmagick and saves edited images and returns path to get edited image
  #
  # FIXME - incorporate into database as a custom-named thumbnail
  #
  def autosize(img_pub_path, opts)
    if opts[:maxwidth]
      if opts[:exact]
        width_opts = "w#{opts[:maxwidth]}"
      else
        width_opts = "mxw#{opts[:maxwidth]}"
      end
    else
      width_opts = "wa"
    end

    if opts[:maxheight]
      if opts[:exact]
        height_opts = "h#{opts[:maxheight]}"
      else
        height_opts = "mxh#{opts[:maxheight]}"
      end
    else
      height_opts = "ha"
    end

    ext = rescue_me(".jpg"){ img_pub_path[img_pub_path.rindex(".")..-1] }
    img_fixed_pub_path = "#{img_pub_path}.#{width_opts}.#{height_opts}#{ext}"

    img_priv_path = "public#{img_pub_path}"
    img_fixed_priv_path = "public#{img_fixed_pub_path}"

    unless File.exists?(img_fixed_priv_path)
      if(File.exists?(img_priv_path))
        begin
          geom = Magick::Geometry.new(opts[:maxwidth], opts[:maxheight])
          img = Magick::Image.read(img_priv_path).first
          altered = img.change_geometry(geom) do |w, h, img|
            img.resize(w, h)
          end
          altered.write img_fixed_priv_path
        rescue
          logger.error("Error writing image auto-resize: #{img_fixed_priv_path}: #{$!}")
        end
      else
        logger.error("File does not exist: #{img_priv_path}")
      end
    end

    return img_fixed_pub_path
  end

end