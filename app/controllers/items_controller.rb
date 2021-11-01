# TODO: clean this up further
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
class ItemsController < ApplicationController
  before_action :logout_if_expired!

  before_action(:require_staff_or_admin!, except: %i[index purge_items])
  before_action(:require_authorization!, only: [:index])
  before_action(:require_admin!, only: [:purge_items])

  def index
    keyword = param_or_cookie(:keyword)
    item_location = param_or_cookie(:location)
    item_type = param_or_cookie(:item_type)
    start_date = param_or_cookie(:date_found)
    end_date = param_or_cookie(:date_foundEnd)
    search_all = param_or_cookie(:searchAll) # TODO: reimplement search_all?

    # TODO: move this logic into the model
    query = keyword.blank? ? Item : Item.query_params(keyword)
    query = query.where(claimed_by: nil).or(Item.where.not(claimed_by: 'Purged'))
    query = query.where(status: 1)

    if (start_date = parse_date_found(start_date))
      query = if (end_date = parse_date_found(end_date))
                query.where('date_found >= ? AND date_found <= ?', start_date, end_date)
              else
                query.where(date_found: start_date)
              end
    end

    query = query.where(item_type: item_type) unless item_type.blank?
    query = query.where(location: item_location) unless item_location.blank? || search_all # TODO: reimplement search_all?
    query = query.order(date_found: :desc)

    @items_found = query.page(params[:page]) # TODO: test pagination
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

    date_found, datetime_found = date_and_datetime_found_values

    # TODO: just use strong parameters
    @item.assign_attributes(
      location: params[:location],
      item_type: params[:item_type],
      description: params[:description],
      updated_by: current_user.user_name,
      found_by: params[:found_by],
      status: params[:status],
      date_found: date_found,
      datetime_found: datetime_found,
      where_found: params[:where_found],
      claimed_by: params[:claimed_by].blank? ? nil : params[:claimed_by]
    )

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

    date_found, datetime_found = date_and_datetime_found_values

    # TODO: just use strong parameters
    @item.assign_attributes(
      location: params[:location],
      item_type: params[:item_type],
      description: params[:description],
      entered_by: current_user.user_name,
      updated_by: current_user.user_name,
      found_by: params[:found_by] || 'anonymous',
      status: 1, # TODO: replace magic number with enum
      date_found: date_found,
      datetime_found: datetime_found,
      where_found: params[:where_found],
      claimed_by: nil
    )

    unless params[:image].nil? || @item.invalid?
      @item.image.attach(params[:image])
      @item.image_url = url_for(@item.image)
    end

    begin
      @item.save!
      render template: 'items/new'
    rescue StandardError => e
      flash_errors(@item, e, now: true)
      @locations_layout = location_setup
      @item_type_layout = item_type_setup
      render template: 'forms/insert_form'
    end
  end

  def purge_items
    purge_date = parse_date_found(params[:purgeTime])

    items_to_purge = Item
      .where(claimed_by: nil).or(Item.where.not(claimed_by: 'Purged'))
      .where(status: 1)
      .where('date_found <= ?', purge_date)

    purged_total = items_to_purge
      .update_all(updated_by: current_user.user_name, claimed_by: 'Purged')

    flash[:success] = "#{purged_total} items purged"

    admin_items
  end

  private

  def date_and_datetime_found_values
    return if (date_found = parse_date_found(params[:date_found])).blank?
    return date_found if (dp_param = params[:time_found]).blank?

    datetime_found_param = "#{params[:date_found]} #{dp_param}"
    datetime_found = Time.strptime(datetime_found_param, '%Y-%m-%d %H:%M').in_time_zone

    [date_found, datetime_found]
  end

  def parse_date_found(df_param)
    return unless df_param

    Date.strptime(df_param, '%Y-%m-%d')
  end

  # TODO: do we really need these cookies here?
  def param_or_cookie(param)
    cookies.delete(param)
    param_value = params[param]
    cookies[param] = param_value unless param_value.blank?
  end

end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/ClassLength
