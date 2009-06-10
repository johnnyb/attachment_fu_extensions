class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  acts_as_list :scope => 'attachable_id = #{attachable_id} and relationship = \'#{relationship}\''

  has_attachment :max_size => 25000000,
                 :storage => :file_system,
                 :path_prefix => "public/images/data/attachments"

  before_validation :force_content_type

  validates_as_attachment

  attr_accessible :uploaded_data, :active, :name, :description, :relationship, :position, :url

  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => { :active => false }

  default_scope :order => 'attachments.position'


  %w{ image audio video }.each do |type|
    named_scope type.pluralize, :conditions => ["attachments.content_type like ?", "#{type}/%"]
  end

  def dup
    new_attachment = Attachment.new
    new_attachment.content_type = self.content_type
    new_attachment.filename = self.filename
    new_attachment.temp_path = "public#{self.public_filename}"
    new_attachment.relationship = self.relationship
    new_attachment.attachable_id = self.attachable_id
    new_attachment.attachable_type = self.attachable_type

    return new_attachment
  end

  # pass in any base mime types, ex: is_mime_type?(:video)
  def is_mime_type?(*args)
    /^(#{args.join('|')})\//.match(content_type).nil?
  end

  def force_content_type
    if content_type.blank?
      self.content_type = 'application/octet-stream'
    end
  end

  # This was needed for an earlier version - not sure if needed now
  # def thumbnails
  #  []
  # end
end
