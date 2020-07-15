class ItemsController < ApplicationController


  def current_user
    cookies[:user_name] 
  end

  def index
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
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
    render template: "items/edit"
  end

  def show 
    @item = Item.find(params[:id])
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
    @item_status_layout = [["Found",1],["Claimed",3]]
  end

  def update
    begin
    @item = Item.find(params[:id])
    @item.update(itemLocation: params[:itemLocation],itemType: params[:itemType],itemDescription: params[:itemDescription],itemUpdatedBy: cookies[:user_name], itemFoundBy: params[:itemFoundBy],itemStatus: params[:itemStatus],itemDate: params[:itemDate], itemFoundAt: params[:itemFoundAt], itemLastModified: Time.now())
    @item.update(claimedBy: params[:claimedBy])
    @item.update(image: params[:image]) unless params[:image].nil?
    @item.update(image_url: url_for(@item.image)) unless !@item.image.attached?
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    render template: "items/all"
  rescue Exception => e
    flash[:notice] = "Item failed to be updated"
    render template: "items/all"
  end
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
    @item.claimedBy = "unclaimed"
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

    locations = {
      1 =>'Doe Circ',
      2 =>'Doe South Entrance',
      3 =>'Moffitt Circ',
      4 =>'UCPD',
      5 => 'Main Desk',
      13 =>'MRC',
      14 =>'Cal1 Card',
      15 =>'Privileges Desk',
      16 =>'Doe North Entrance',
      17=>'Moffitt 3rd Fl Entrance',
      18 =>'Moffitt 4th Fl Entrance',
      19 =>'Gardner Stacks Level C',
      20 => 'Library Security'
    }

    legacy_types = {
      1 => 'Books',
      2 => 'Clothing',
      3 =>'Glasses',
      4 =>'Keys',
      5 => 'Phone',
      6=> 'Wallet',
      7 =>'ID (license or Cal card)',
      8 =>'MP3 player',
      9 =>'Other',
      17=> 'iPod',
      19 =>'Electronics'
    }

    @item = Item.new()
    @item.itemDate = modified_item_values[1]
    @item.itemFoundAt = modified_item_values[2]
    @item.itemLocation = modified_item_values[3]
    @item.itemType = legacy_types[modified_item_values[5].to_i]
    @item.itemDescription= modified_item_values[6]
    @item.itemLastModified=Time.now();
    @item.itemStatus = modified_item_values[8]
    @item.itemEnteredBy = modified_item_values[9]
    @item.itemImage = "none";
    @item.itemObsolete = 0;
    @item.itemUpdatedBy = modified_item_values[9]
    @item.itemFoundBy = modified_item_values[9]
    @item.libID = modified_item_values[16];
    @item.created_at =Time.now();
    @item.updated_at = Time.now();
    @item.claimedBy = 'unknown'
    begin
     @item.save!
    rescue
    end
  end
 end

  def purge_items
    purge_raw= params[:purgeTime]
    purge_date = Time.parse(purge_raw)
    purged_total = 0

    Item.find_each do | item |
        if item.created_at <= Time.parse(purge_date.to_s) && item.itemStatus != 3
          item.update(itemStatus: 3, claimedBy: "Purged" )
          purged_total = purged_total + 1
        end
    end
    flash.now.alert = purged_total.to_s + " items purged"
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    render template: "items/all"
  end


  def destroy
    Item.delete(params[:id])
    @Items = Item.all
    redirect_back(fallback_location: root_path)
  end
end