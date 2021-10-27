class ItemsController < ApplicationController
  before_action :logout_if_expired!
  before_action :authenticate!

  before_action(:require_staff_or_admin!, except: [:found, :param_search]) # TODO: is this right?
  before_action(:require_admin!, only: [:purge_items])

  def found
    @items_found = Item.found.page params[:page]

    render template: 'items/found'
  end

  def param_search
    params[:itemLocation] = cookies[:itemLocation] unless params[:itemLocation]
    params[:searchAll] = cookies[:searchAll] unless params[:searchAll]
    params[:itemType] = cookies[:itemType] unless params[:itemType]
    params[:keyword] = cookies[:keyword] unless params[:keyword]
    params[:itemDate] = cookies[:itemDate] unless params[:itemDate]

    if !params[:keyword].blank?
      @items = Item.query_params(params[:keyword])
    else
      @items = Item.all
    end

    unless params[:searchAll] || params[:itemLocation] == 'none'
      @items = @items.select { |item| item.itemLocation == params[:itemLocation] } unless params[:itemLocation].nil?
    end
    unless params[:searchAll] || params[:itemType] == 'none'
      @items = @items.select { |item| item.itemType == params[:itemType] } unless params[:itemType].nil?
    end

    unless params[:itemDate].blank? || params[:itemDate] == "itemDate"
      item_date_raw = params[:itemDate]
      item_date_parsed = Time.parse(item_date_raw)
      if params[:itemDateEnd].blank? || params[:itemDateEnd] == "itemDateEnd"
        @items = @items.select { |item| item.itemDate == DateTime.parse(item_date_parsed.to_s) }
      else
        item_date_end_raw = params[:itemDateEnd]
        item_date_end_parsed = Time.parse(item_date_end_raw)
        @items = @items.select { |item|
          item.itemDate >= DateTime.parse(item_date_parsed.to_s) && item.itemDate <= DateTime.parse(item_date_end_parsed.to_s)
        }
      end
    end

    @items_found = @items.select { |item| item.itemStatus == 1 && item.claimedBy != 'Purged' }
    @items_found = @items_found.sort_by { |item| item.itemDate || Time.zone.at(0) }.reverse

    cookies[:itemLocation] = params[:itemLocation]
    cookies[:searchAll] = params[:searchAll]
    cookies[:itemType] = params[:itemType]
    cookies[:keyword] = params[:keyword]
    cookies[:itemDate] = params[:itemDate]

    @items_found = Kaminari.paginate_array(@items_found.reverse).page(params[:page])

    render template: 'items/found'
  end

  def admin_items
    @items_found = Item.found
    @items_found = @items_found.sort_by(&:itemDate).reverse
    @items_found = Kaminari.paginate_array(@items_found.reverse).page(params[:page])
    @items_claimed = Item.claimed
    @items_claimed = @items_claimed.sort_by(&:itemDate).reverse
    @items_claimed = Kaminari.paginate_array(@items_claimed.reverse).page(params[:claimed_page])

    render template: 'items/admin_items'
  end

  def claimed_items
    # TODO: clean this up
    @items_claimed = current_user.administrator? ? Item.claimed : Item.where(itemStatus: 3).where.not(claimedBy: 'Purged')
    @items_claimed = @items_claimed.sort_by(&:itemDate).reverse
    @items_claimed = Kaminari.paginate_array(@items_claimed.reverse).page(params[:page])

    render template: 'items/admin_claimed'
  end

  def edit
    @item = Item.find(params[:id])
    require_admin! if @item.claimed?

    @locations_layout = location_setup
    @item_type_layout = item_type_setup
    # TODO: replace magic number with enum
    @item_status_layout = [['Found', 1], ['Claimed', 3]]

    render template: 'items/edit'
  end

  def show
    @item = Item.find(params[:id])
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
    # TODO: replace magic number with enum
    @item_status_layout = [['Found', 1], ['Claimed', 3]]
  end

  def update
    @item = Item.find(params[:id])
    require_admin! if @item.claimed?

    # TODO: just use strong parameters

    @item.itemLocation = params[:itemLocation]
    @item.itemType = params[:itemType]
    @item.itemDescription = params[:itemDescription]
    @item.itemUpdatedBy = current_user.user_name
    @item.itemFoundBy = params[:itemFoundBy]
    @item.itemStatus = params[:itemStatus]
    @item.itemDate = params[:itemDate]
    @item.itemFoundAt = params[:itemFoundAt]
    @item.itemLastModified = Time.now
    @item.whereFound = params[:whereFound]
    @item.claimedBy = params[:claimedBy].blank? ? nil : params[:claimedBy]

    unless params[:image].nil? || @item.invalid?
      @item.image.attach(params[:image])
      @item.image_url = url_for(@item.image)
    end

    begin
      @item.save!
    rescue StandardError => e
      flash[:alert] = 'Error: Item has invalid parameters'
      logger.error(e)
    end

    # TODO: why do we need these?
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed

    render template: 'items/updated'
  end

  def create
    @item = Item.new
    @item.itemDate = params[:itemDate] || Time.now # TODO: use Date.current
    @item.itemFoundAt = params[:itemFoundAt] || Time.now # TODO: use Time.current
    @item.itemLocation = params[:itemLocation]
    @item.itemType = params[:itemType]
    @item.itemDescription = params[:itemDescription]
    @item.itemLastModified = Time.now
    # TODO: replace magic number with enum
    @item.itemStatus = 1
    @item.itemEnteredBy = current_user.user_name
    @item.itemObsolete = 0
    @item.itemUpdatedBy = current_user.user_name
    @item.itemFoundBy = params[:itemFoundBy] || 'anonymous'
    @item.libID = 115 # TODO: do we need this?
    @item.created_at = Time.now # TODO: let ActiveRecord set timestamps
    @item.updated_at = Time.now # TODO: let ActiveRecord set timestamps
    @item.claimedBy = ''
    @item.whereFound = params[:whereFound] || 'unknown'

    unless params[:image].nil? || @item.invalid?
      @item.image.attach(params[:image])
      @item.image_url = url_for(@item.image)
    end

    begin
      @item.save!
      render template: 'items/new'
    rescue StandardError => e
      @locations_layout = location_setup
      @item_type_layout = item_type_setup
      flash.now.alert = 'Item rejected. Missing required fields'
      logger.error(e)
      render template: 'forms/insert_form'
    end
  end

  def item_params
    params.permit(:itemLocation, :itemType, :itemDescription, :image)
  end

  def purge_items
    purge_raw = params[:purgeTime]
    purge_date = Time.parse(purge_raw)
    purged_total = 0

    Item.find_each do |item|
      if item.itemDate <= DateTime.parse(purge_date.to_s) && item.claimedBy != 'Purged' && item.itemStatus == 1
        item.update(itemUpdatedBy: current_user.user_name, itemLastModified: Time.now, claimedBy: 'Purged')
        purged_total += 1
      end
    end
    flash[:success] = purged_total.to_s + ' items purged'
    admin_items
  end
end
