class ItemsController < ApplicationController

  def index
    @items = Item.found
    render template: "items/all"
  end

  def found
    @items_found = Item.found
    render template: "items/all"
  end

  def all
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    redirect_back(fallback_location: root_path)
  end

  def param_search
    @items = Item.query_params(params)
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

  def update
    @item = Item.find(params[:id])
    @item.update(itemLocation: params[:itemLocation],itemType: params[:itemType],itemDescription: params[:itemDescription],itemUpdatedBy: cookies[:uid], itemStatus: params[:itemStatus],updated_at: Time.now)
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    redirect_to root_path
  end

  def claim_item
    @item = Item.find(params[:id])
    @item.update(itemStatus: 3, itemFoundBy: params[:claimer])
    @items = Item.all
    redirect_to home_path
  end

  def create
    @Item = Item.new()
    @Item.itemDate = Time.now();
    @Item.itemFoundAt = Time.now();
    @Item.itemLocation = params[:itemLocation];
    @Item.itemType = params[:itemType];
    @Item.itemDescription= params[:itemDescription];
    @Item.itemLastModified=Time.now();
    @Item.itemStatus = 1;
    @Item.itemEnteredBy = "unknown";
    @Item.itemImage = "none";
    @Item.itemObsolete = 0;
    @Item.itemUpdatedBy = "??????";
    @Item.itemFoundBy = params[:itemFoundBy] || 'anonymous';
    @Item.libID = 115;
    @Item.created_at =Time.now();
    @Item.updated_at = Time.now();

    if @Item.save!
      @items = @Item
      render template: "items/new"
    else
       @items = Item.all
       render template: "items/all"
    end
  end

  def item_params
    params.permit(:itemLocation, :itemType, :itemDescription)
 end



  def destroy
    Item.delete(params[:id])
    @Items = Item.all
    redirect_back(fallback_location: root_path)
  end
end