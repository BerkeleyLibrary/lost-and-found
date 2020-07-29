class ItemsController < ApplicationController

  def current_user
    cookies[:user_name]
  end

  def index
    @items = Item.query_params(cookies[:keyword])
    unless cookies[:searchAll] || cookies[:itemLocation] == 'none'
      @items = @items.select { |item| item.itemLocation == cookies[:itemLocation] }
    end
    unless cookies[:searchAll] || cookies[:itemType] == 'none'
      @items = @items.select { |item| item.itemType == cookies[:itemType] }
    end
    @items_found = @items.select { |item| item.itemStatus == 1 }
    @items_claimed = @items.select { |item| item.itemStatus == 3 }
    render template: 'items/all'
  end

  def found
    @items_found = Item.found
    render template: 'items/found'
  end

  def all
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    redirect_back(fallback_location: root_path)
  end

  def param_search
    @items = Item.query_params(params[:keyword])
    unless params[:searchAll] || params[:itemLocation] == 'none'
      @items = @items.select { |item| item.itemLocation == params[:itemLocation] }
    end
    unless params[:searchAll] || params[:itemType] == 'none'
      @items = @items.select { |item| item.itemType == params[:itemType] }
    end
    @items_found = @items.select { |item| item.itemStatus == 1 }
    @items_claimed = @items.select { |item| item.itemStatus == 3 }

    cookies[:itemLocation] = params[:itemLocation]
    cookies[:searchAll] = params[:searchAll]
    cookies[:itemType] = params[:itemType]
    cookies[:keyword] = params[:keyword]

    render template: 'items/all'
  end

  def admin_items
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed

    render template: 'items/all'
  end

  def claimed_items
    @items_claimed = Item.claimed
    render template: 'items/admin_claimed'
  end

  def show
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
  end

  def edit
    @item = Item.find(params[:id])
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
    @item_status_layout = [['Found', 1], ['Claimed', 3]]
    render template: 'items/edit'
  end

  def show
    @item = Item.find(params[:id])
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
    @item_status_layout = [['Found', 1], ['Claimed', 3]]
  end

  def update
    begin
      @item = Item.find(params[:id])
      @item.update(itemLocation: params[:itemLocation], itemType: params[:itemType], itemDescription: params[:itemDescription], itemUpdatedBy: cookies[:user_name], itemFoundBy: params[:itemFoundBy], itemStatus: params[:itemStatus], itemDate: params[:itemDate], itemFoundAt: params[:itemFoundAt], itemLastModified: Time.now, whereFound: params[:whereFound])
      @item.update(claimedBy: params[:claimedBy])
      @item.update(image: params[:image]) unless params[:image].nil?
      @item.update(image_url: url_for(@item.image)) if @item.image.attached?
      @items = Item.all
      @items_found = Item.found
      @items_claimed = Item.claimed
    rescue Exception => e
      flash[:alert] = 'Error: Item has invalid parameters'
    end
    render template: 'items/all'
  end

  def create
    @item = Item.new
    @item.itemDate = params[:itemDate] || Time.now
    @item.itemFoundAt = params[:itemFoundAt] || Time.now
    @item.itemLocation = params[:itemLocation]
    @item.itemType = params[:itemType]
    @item.itemDescription = params[:itemDescription]
    @item.itemLastModified = Time.now
    @item.itemStatus = 1
    @item.itemEnteredBy = 'unknown'
    @item.itemImage = 'none'
    @item.itemObsolete = 0
    @item.itemUpdatedBy = cookies[:user_name]
    @item.itemFoundBy = params[:itemFoundBy] || 'anonymous'
    @item.libID = 115
    @item.created_at = Time.now
    @item.updated_at = Time.now
    @item.claimedBy = 'unclaimed'
    @item.whereFound = params[:whereFound] || 'unknown'
    @item.image.attach(params[:image])
    !params[:image].nil? ? @item.image_url = url_for(@item.image) : 'NONE'
    begin
      @item.save!
      render template: 'items/new'
    rescue StandardError
      @locations_layout = location_setup
      @item_type_layout = item_type_setup
      flash.now.alert = 'Item rejected. Missing required fields'
      render template: 'forms/insert_form'
    end
  end

  def item_params
    params.permit(:itemLocation, :itemType, :itemDescription, :image)
 end

  def batch_upload
    uploaded_file = params[:batch_file]
    file_content = uploaded_file.read
    upload_items = file_content.split('),(')
    upload_items.each do |item|
      item[0] = '' if item[0] == '('
      item[item.length - 1] = '' if item[item.length - 1] == ')'
      raw_item_values = item.split(',')
      modified_item_values = []
      raw_item_values.each do |value|
        modified_item_values.push(value.gsub("'", '').strip)
      end

      locations = {
        1 => 'doe circ',
        2 => 'doe south entrance',
        3 => 'moffitt circ',
        4 => 'UCPD',
        5 => 'main desk',
        13 => 'MRC',
        14 => 'cal1 card',
        15 => 'privileges desk',
        16 => 'doe north entrance',
        17 => 'moffitt 3rd fl entrance',
        18 => 'moffitt 4th fl entrance',
        19 => 'gardner stacks level c',
        20 => 'library security'
      }

      legacy_types = {
        1 => 'books',
        2 => 'clothing',
        3 => 'glasses',
        4 => 'keys',
        5 => 'phone',
        6 => 'wallet',
        7 => 'id (license or cal card)',
        8 => 'mp3 player',
        9 => 'other',
        17 => 'ipod',
        19 => 'electronics'
      }

      @item = Item.new
      @item.itemDate = modified_item_values[1]
      @item.itemFoundAt = modified_item_values[2]
      @item.whereFound = modified_item_values[3]
      @item.itemLocation = locations[modified_item_values[4].to_i]
      @item.itemType = legacy_types[modified_item_values[5].to_i]
      @item.itemDescription = modified_item_values[6].gsub(/[\r\n]+/m, "")
      @item.itemLastModified = Time.now
      @item.itemStatus = modified_item_values[8]
      @item.itemEnteredBy = modified_item_values[9]
      @item.itemImage = 'none'
      @item.itemObsolete = 0
      @item.itemUpdatedBy = modified_item_values[9]
      @item.itemFoundBy = modified_item_values[9]
      @item.libID = modified_item_values[16]
      @item.created_at = Time.now
      @item.updated_at = Time.now
      @item.claimedBy = 'unknown'
      begin
        @item.save!
      rescue StandardError
      end
    end
  end

  def purge_items
    purge_raw = params[:purgeTime]
    purge_date = Time.parse(purge_raw)
    purged_total = 0
    deleted_total = 0

    Item.find_each do |item|
      if item.created_at <= DateTime.parse(purge_date.to_s) && item.itemStatus != 3
        item.update(itemStatus: 3, claimedBy: 'Purged')
        purged_total += 1
      end
    end
    flash[:success] = purged_total.to_s + ' items purged'
    if deleted_total > 0
      flash[:success] = deleted_total.to_s + ' duplicates data deleted'
    end
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed
    render template: 'items/all'
  end

  def destroy
    Item.delete(params[:id])
    @Items = Item.all
    redirect_back(fallback_location: root_path)
  end
end
