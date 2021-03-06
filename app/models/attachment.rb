class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  has_attachment :max_size => 25000000,
                 :storage => :file_system,
                 :path_prefix => "public/images/data/attachments"

  before_validation :force_content_type

  validates_as_attachment

  attr_accessible :uploaded_data, :active, :name, :description, :relationship, :position, :url

  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => { :active => false }

  default_scope :order => 'attachments.position, attachments.id'


  %w{ image audio video text pdf }.each do |type|
    named_scope type.pluralize, :conditions => ["attachments.content_type like ?", "#{type}/%"]
  end

  named_scope :documents, :conditions => ["pdf", "excel", "word"].map{|dt| "attachments.content_type #{ilike_keyword} '%#{dt}%'"}.join(" OR ")

  named_scope :of_media_type, lambda{|tlist|
    condition_list = []
    value_list = []
    tlist.each do |ctype|
      condition_list.push("attachments.content_type like ?")
      value_list.push("#{ctype}/%")
    end
    return { :conditions => [condition_list.join(" OR "), *value_list] }
  }

  def dup
    new_attachment = Attachment.new
    new_attachment.content_type = self.content_type
    new_attachment.filename = self.filename
    new_attachment.temp_paths.unshift("public#{self.public_filename}")
    new_attachment.relationship = self.relationship
    new_attachment.attachable_id = self.attachable_id
    new_attachment.attachable_type = self.attachable_type

    return new_attachment
  end

  # pass in any base mime types, ex: is_mime_type?(:video)
  def is_mime_type?(*args)
    return !(/^(#{args.join('|')})\//.match(content_type).nil?)
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
