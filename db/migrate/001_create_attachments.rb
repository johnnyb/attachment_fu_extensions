class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      # Identifier
      t.string :name

      # Extra content
      t.text :description
      t.text :extra_info 
      t.text :link_url

      # Relationship
      t.integer :parent_id

      # Metadata
      t.string :content_type
      t.string :filename
      t.string :thumbnail
      t.integer :size, :width, :height
     
      # Attachment Relationship
      t.integer :attachable_id
      t.string :attachable_type
      t.string :relationship
      t.integer :position 

      #Active/inactive
      t.boolean :active
    end
  end

  def self.down
  end
end
