class AttachmentModelGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "app/views/attachments"

      ["app/controllers/attachments_controller.rb", "app/models/attachment.rb", "app/views/attachments/index.html.erb", "app/views/attachments/attachment_order.js.rjs", "app/views/attachments/_entry.html.erb"].each do |fname|
        m.file "../../../#{fname}", fname
      end
      m.migration_template "../../../db/migrate/001_create_attachments.rb", "db/migrate"
    end
  end
end
