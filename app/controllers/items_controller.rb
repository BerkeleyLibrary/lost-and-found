class ItemsController < ApplicationController
  before_action :logout_if_expired!

  before_action(:require_staff_or_admin!, except: [:index, :purge_items])
  before_action(:require_authorization!, only: [:index])
  before_action(:require_admin!, only: [:purge_items])

  def index
    keyword = param_or_cookie(:keyword)
    item_location = param_or_cookie(:itemLocation)
    item_type = param_or_cookie(:itemType)
    search_all = param_or_cookie(:searchAll)
    start_date = param_or_cookie(:itemDate)
    end_date = param_or_cookie(:itemDateEnd)

    # TODO: move this logic into the model
    # TODO: just construct the right SQL query to begin with instead of filtering in the app

    if keyword.blank?
      @items = Item.all
    else
      @items = Item.query_params(keyword)
    end

    unless search_all || item_location.blank?
      @items = @items.select { |item| item.itemLocation == item_location }
    end
    unless search_all || item_type.blank?
      @items = @items.select { |item| item.itemType == item_type } unless item_type.nil?
    end

    unless start_date.blank?
      item_date_raw = start_date
      item_date_parsed = Time.parse(item_date_raw)
      if end_date.blank?
        @items = @items.select { |item| item.itemDate == DateTime.parse(item_date_parsed.to_s) }
      else
        item_date_end_raw = end_date
        item_date_end_parsed = Time.parse(item_date_end_raw)
        @items = @items.select { |item|
          item.itemDate >= DateTime.parse(item_date_parsed.to_s) && item.itemDate <= DateTime.parse(item_date_end_parsed.to_s)
        }
      end
    end

    @items_found = @items.select { |item| item.itemStatus == 1 && item.claimedBy != 'Purged' }
    @items_found = @items_found.sort_by { |item| item.itemDate || Time.zone.at(0) }.reverse

    @items_found = Kaminari.paginate_array(@items_found.reverse).page(params[:page])
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
      flash_errors(@item, e)
    end

    # TODO: why do we need these?
    @items = Item.all
    @items_found = Item.found
    @items_claimed = Item.claimed

    render template: 'items/updated'
  end

  def create
    @item = Item.new
    @item.itemDate = params[:itemDate]
    @item.itemFoundAt = params[:itemFoundAt] || Time.current
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
    @item.whereFound = params[:whereFound]

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

  private

  # TODO: do we really need these cookies here?
  def param_or_cookie(param)
    cookies.delete(param)
    param_value = params[param]
    cookies[param] = param_value unless param_value.blank?
  end

end
