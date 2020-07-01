class ItemTypesController < ApplicationController

    def all
      @item_types = ItemType.all
    end

    def create
      @ItemType = ItemType.new()
      @ItemType.type_name = params[:type_name]
      @ItemType.type_active = true
      @ItemType.updated_at = Time.now()
      @ItemType.updated_by = cookies[:user_name]

      if @ItemType.save!
        @item_types = ItemType.all
        redirect_back(fallback_location: root_path)
      else
        @item_types = ItemType.all
        redirect_back(fallback_location: root_path)
      end
    end

    def edit
      @itemType = ItemType.find(params[:id])
    end

    def update
      active = params[:type_active] == "true"
      @itemType = ItemType.find(params[:id])
      @itemType.update(type_name: params[:type_name], type_active: active, updated_at: Time.now(), updated_by: cookies[:user_name])
      @itemTypes = ItemType.all
      redirect_to admin_item_types_path
    end

    def change_status
      @itemType = ItemType.find(params[:id])
      @itemType.update(type_active: !@itemType.type_active)
      @itemTypes = ItemType.all
      redirect_back(fallback_location: root_path)
    end

    def destroy
        ItemType.delete(params[:id])
        @ItemTypes = ItemType.all
        redirect_back(fallback_location: root_path)
    end

    def batch_upload
      uploaded_file = params[:batch_file]
      file_content = uploaded_file.read
      upload_items = file_content.split("),(");
      upload_items.each do | item |
        item[0] = '' if item[0]=='('
        item[item.length-1] = "" if item[item.length-1] == ")"
        raw_item_values = item.split(',')
        modified_item_values = []
        raw_item_values.each do | value|
          modified_item_values.push(value.gsub("'","").strip())
        end

        @ItemType = ItemType.new()
        @ItemType.type_name = modified_item_values[1]
        @ItemType.type_active = true
        @ItemType.updated_at = Time.now()
        @ItemType.updated_by = "Legacy"
        begin
         @ItemType.save!
        rescue
        end
      end
     end



end