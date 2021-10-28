class ItemsController < ApplicationController
  before_action :logout_if_expired!

  before_action(:require_staff_or_admin!, except: %i[index purge_items])
  before_action(:require_authorization!, only: [:index])
  before_action(:require_admin!, only: [:purge_items])

  def index
    keyword = param_or_cookie(:keyword)
    item_location = param_or_cookie(:location)
    item_type = param_or_cookie(:item_type)
    search_all = param_or_cookie(:searchAll)
    start_date = param_or_cookie(:date_found)
    end_date = param_or_cookie(:date_foundEnd)

    # TODO: move this logic into the model
    # TODO: just construct the right SQL query to begin with instead of filtering in the app

    @items = if keyword.blank?
               Item.all
             else
               Item.query_params(keyword)
             end

    @items = @items.select { |item| item.location == item_location } unless search_all || item_location.blank?
    @items = @items.select { |item| item.item_type == item_type } if !(search_all || item_type.blank?) && !item_type.nil?

    unless start_date.blank?
      date_found_raw = start_date
      date_found_parsed = Time.parse(date_found_raw)
      if end_date.blank?
        @items = @items.select { |item| item.date_found == DateTime.parse(date_found_parsed.to_s) }
      else
        date_found_end_raw = end_date
        date_found_end_parsed = Time.parse(date_found_end_raw)
        @items = @items.select do |item|
          item.date_found >= DateTime.parse(date_found_parsed.to_s) && item.date_found <= DateTime.parse(date_found_end_parsed.to_s)
        end
      end
    end

    @items_found = @items.select { |item| item.status == 1 && item.claimed_by != 'Purged' }
    @items_found = @items_found.sort_by { |item| item.date_found || Time.zone.at(0) }.reverse

    @items_found = Kaminari.paginate_array(@items_found.reverse).page(params[:page])
  end

  def admin_items
    @items_found = Item.found
    @items_found = @items_found.sort_by(&:date_found).reverse
    @items_found = Kaminari.paginate_array(@items_found.reverse).page(params[:page])
    @items_claimed = Item.claimed
    @items_claimed = @items_claimed.sort_by(&:date_found).reverse
    @items_claimed = Kaminari.paginate_array(@items_claimed.reverse).page(params[:claimed_page])

    render template: 'items/admin_items'
  end

  def claimed_items
    # TODO: clean this up
    @items_claimed = current_user.administrator? ? Item.claimed : Item.where(status: 3).where.not(claimed_by: 'Purged')
    @items_claimed = @items_claimed.sort_by(&:date_found).reverse
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

    @item.location = params[:location]
    @item.item_type = params[:item_type]
    @item.description = params[:description]
    @item.updated_by = current_user.user_name
    @item.found_by = params[:found_by]
    @item.status = params[:status]
    @item.date_found = params[:date_found]
    @item.found_at = params[:found_at]
    @item.itemLastModified = Time.now
    @item.where_found = params[:where_found]
    @item.claimed_by = params[:claimed_by].blank? ? nil : params[:claimed_by]

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
    @item.date_found = params[:date_found]
    @item.found_at = params[:found_at] || Time.current
    @item.location = params[:location]
    @item.item_type = params[:item_type]
    @item.description = params[:description]
    @item.itemLastModified = Time.now
    # TODO: replace magic number with enum
    @item.status = 1
    @item.entered_by = current_user.user_name
    @item.itemObsolete = 0
    @item.updated_by = current_user.user_name
    @item.found_by = params[:found_by] || 'anonymous'
    @item.libID = 115 # TODO: do we need this?
    @item.created_at = Time.now # TODO: let ActiveRecord set timestamps
    @item.updated_at = Time.now # TODO: let ActiveRecord set timestamps
    @item.claimed_by = ''
    @item.where_found = params[:where_found]

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

  def purge_items
    purge_raw = params[:purgeTime]
    purge_date = Time.parse(purge_raw)
    purged_total = 0

    Item.find_each do |item|
      if item.date_found <= DateTime.parse(purge_date.to_s) && item.claimed_by != 'Purged' && item.status == 1
        item.update(updated_by: current_user.user_name, itemLastModified: Time.now, claimed_by: 'Purged')
        purged_total += 1
      end
    end
    flash[:success] = "#{purged_total} items purged"
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
