class ItemsController < ApplicationController


  def current_user
    cookies[:user_name] 
  end

  def index
    @items = Item.found
    render template: "items/all"
  end

  def found
    @items_found = Item.found
    render template: "items/found"
  end

  def all
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    redirect_back(fallback_location: root_path)
  end

  def param_search
    @items = Item.query_params(params)
    @items = @items.select{ |item| item.itemLocation == params[:itemLocation] } unless params[:searchAll] || params[:itemLocation] == 'none'
    @items = @items.select{ |item| item.itemType == params[:itemType] } unless params[:searchAll] || params[:itemType] == 'none'
    @items_found = @items.select{ |item| item.itemStatus == 1 }
    @items_claimed = @items.select{ |item| item.itemStatus == 3 }
    render template: "items/all"
  end

  def show
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
  end

  def new

  end

  def edit
    @item = Item.find(params[:id])
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
    @item_status_layout = [["Found",1],["Claimed",3]]
  end

  def show 
    @item = Item.find(params[:id])
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
    @item_status_layout = [["Found",1],["Claimed",3]]
  end

  def update
    @item = Item.find(params[:id])
    @item.update(itemLocation: params[:itemLocation],itemType: params[:itemType],itemDescription: params[:itemDescription],itemUpdatedBy: cookies[:user_name], itemFoundBy: params[:itemFoundBy],itemStatus: params[:itemStatus],updated_at: Time.now)
    @item.update(image: params[:image]) unless params[:image].nil?
    @item.update(image_url: url_for(@item.image)) unless !@item.image.attached?
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    render template: "items/all"
  end

  def create
    @item = Item.new()
    @item.itemDate = params[:itemDate] || Time.now
    @item.itemFoundAt = params[:itemFoundAt] || Time.now
    @item.itemLocation = params[:itemLocation];
    @item.itemType = params[:itemType];
    @item.itemDescription= params[:itemDescription];
    @item.itemLastModified=Time.now();
    @item.itemStatus = 1;
    @item.itemEnteredBy = "unknown";
    @item.itemImage = "none";
    @item.itemObsolete = 0;
    @item.itemUpdatedBy = cookies[:user_name];
    @item.itemFoundBy = params[:itemFoundBy] || 'anonymous';
    @item.libID = 115;
    @item.created_at =Time.now();
    @item.updated_at = Time.now();
    @item.image.attach( params[:image])
    params[:image] != nil ? @item.image_url = (url_for(@item.image)) : 'NONE'
    begin
      @item.save!
      render template: "items/new"
    rescue
      @locations_layout = location_setup
      @item_type_layout = item_type_setup
        flash.now.alert = "Item rejected. Missing required fields"
        render template: "forms/insert_form"
    end
  end

  def item_params
    params.permit(:itemLocation, :itemType, :itemDescription, :image)
 end



  def destroy
    Item.delete(params[:id])
    @Items = Item.all
    redirect_back(fallback_location: root_path)
  end
end