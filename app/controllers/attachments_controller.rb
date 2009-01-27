class AttachmentsController < ApplicationController
  before_filter :setup_primary
  
  layout "popup"

  @@field_params = [:active, :name, :description, :image, :description_class, :blank, :url]
  @@static_params = @@field_params + [:object_id, :object_type, :mode, :relationship]
  
  def validate_permissions_for(obj)
    # PUT YOUR OWN VALIDATION CODE HERE
  end

  def static_params_hash
    hsh = {}
    @@static_params.each do |param|
      hsh[param] = params[param]
    end

    return hsh
  end

  def index
    respond_to do |format|
      format.html {
        #Setup field names for HTML form listing
        @fields = {}

        @@field_params.each do |field_sym|
          unless params[field_sym].blank?
            @fields[field_sym] = params[field_sym]
          end
        end
        if @fields.empty?
          if params[:mode] == :single
            @fields = {}
          else
            @fields = { :active => "Active", :name => "Name", :description => "Description", :description_class => "small" }
          end
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

    redirect_to attachments_path(static_params_hash)
  end

  # NOTE - this is not "show" because we aren't showing the whole record
  def view
    # FIXME - need a way to distinguish between download and inline docs
    send_file(@attachment.filename)
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

    @static_params_hash = static_params_hash

    validate_permissions_for(@primary)
  end

end
