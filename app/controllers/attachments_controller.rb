class AttachmentsController < ApplicationController
  before_filter :setup_primary
  
  layout "popup"
  
  def index
    respond_to do |format|
      format.html {
        #Setup field names for HTML form listing
        @fields = {}
        [:active, :name, :description, :image, :description_class, :blank, :url].each do |field_sym|
          unless params[field_sym].blank?
            @fields[field_sym] = params[field_sym]
          end
        end
        if @fields.empty?
          @fields = { :active => "Active", :name => "Name", :description => "Description", :description_class => "small" }
        end
      }
    end
  end
  
  def update
    params.each do |key, val|
      key = key.to_s
      if key[0..15] == "attachment_info_"
        if key[16..18] == "new"
          if val[:uploaded_data].size > 0
            position = key[20..-1].to_i + @primary.send("#{@relationship}").size
            attachment = @primary.send("create_#{@relationship}_attachment", val)
            attachment.position = position
            attachment.save
          end
        else
          id = key[25..-1].to_i
          attachment = @primary.send("update_#{@relationship}_attachment", id, val)          
        end
      end
    end
    
    unless params[:deletions].blank?
      params[:deletions].each do |attachment_id|
        @primary.send(@relationship).find(attachment_id).destroy
      end
    end
    
    redirect_to attachments_path(:object_id => @primary, :object_type => @primary.class, :title => @title, :relationship => @relationship)
  end

  def view
    if @attachment.private?
      #FIXME - something here
    else
      redirect_to @attachment.public_filename
    end
  end

  def attachment_order
    @primary.send(@relationship).each do |attachment|
      attachment.position = params[:attachment_list].index(attachment.id.to_s)
      attachment.save!
    end
  end  

  private

  def setup_primary
    @relationship = params[:relationship].intern
    @title = params[:title]
    primary_type = params[:object_type]
    primary_id = params[:object_id]

    @primary = Kernel.const_get(primary_type).find(primary_id)

    validate_permissions_for(@primary)
  end

  def validate_permissions_for(obj)
    # PUT YOUR OWN VALIDATION CODE HERE
  end
end
