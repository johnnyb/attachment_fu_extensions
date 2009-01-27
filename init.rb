require "attachment_fu_extensions"

ActiveRecord::Base.send(:include, AttachmentFuExtensions)
ActionView::Base.send(:include, AttachmentFuExtensionsHelper)
ActionController::Base.send(:include, AttachmentFuExtensionsHelper)
