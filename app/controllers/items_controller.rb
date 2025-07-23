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
    end_date = param_or_cookie(:date_found_end)
    search_all = param_or_cookie(:searchAll) # TODO: reimplement search_all?

    # TODO: move all this logic into the model

    keywords = parse_keywords(keyword)
    query = Item.by_keywords(keywords)

    if (start_date = parse_date_found(start_date))
      query = if (end_date = parse_date_found(end_date))
                query.where('date_found >= ? AND date_found <= ?', start_date, end_date)
              else
                query.where(date_found: start_date)
              end
    end

    query = query.where(item_type: item_type) unless item_type.blank?
    query = query.where(location: item_location) unless item_location.blank? || search_all # TODO: reimplement search_all?

    query = order_by_date_desc(query)

    @unclaimed_items = query.page(params[:page]) # TODO: test pagination
  end

  def admin_items
    @unclaimed_items = Item.unclaimed
    @unclaimed_items = @unclaimed_items.sort_by(&:date_found).reverse
    @unclaimed_items = Kaminari.paginate_array(@unclaimed_items.reverse).page(params[:page])
    @items_claimed = Item.claimed
    @items_claimed = @items_claimed.sort_by(&:date_found).reverse
    @items_claimed = Kaminari.paginate_array(@items_claimed.reverse).page(params[:claimed_page])
    @purged = false
  end

  def claimed_items
    # TODO: clean this up
    @purged = current_user.administrator?
    query = @purged ? Item.claimed.or(Item.purged) : Item.claimed
    query = order_by_date_desc(query)
    @items_claimed = query.page(params[:claimed_page])
  end

  def edit
    @item = Item.find(params[:id])
    require_admin! if @item.claimed?

    # TODO: stop having to do this
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
  end

  def show
    @item = Item.find(params[:id])

    # TODO: stop having to do this
    @locations_layout = location_setup
    @item_type_layout = item_type_setup
  end

  def update
    @item = Item.find(params[:id])
    require_admin! if @item.claimed?

    date_found, datetime_found = date_and_datetime_found_values

    # TODO: just use strong parameters
    claimed = params[:claimed] == '1'
    claimed_by = params[:claimed_by].blank? ? nil : params[:claimed_by]

    @item.assign_attributes(
      location: params[:location],
      item_type: params[:item_type],
      description: params[:description],
      updated_by: current_user.user_name,
      found_by: params[:found_by],
      date_found: date_found,
      datetime_found: datetime_found,
      where_found: params[:where_found],
      claimed: claimed,
      claimed_by: claimed_by
    )

    @item.image.attach(params[:image]) unless params[:image].nil? || @item.invalid?

    begin
      @item.save!
      @item.update!(image_url: url_for(@item.image)) unless params[:image].nil?
      flash[:success] = 'Item updated'
      redirect_to item_url(@item.id)
    rescue StandardError => e
      flash_errors(@item, e)

      # TODO: stop having to do this
      @locations_layout = location_setup
      @item_type_layout = item_type_setup
      render 'items/edit', status: :unprocessable_entity
    end
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
      date_found: date_found,
      datetime_found: datetime_found,
      where_found: params[:where_found],
      claimed_by: nil
    )

    @item.image.attach(params[:image]) unless params[:image].nil? || @item.invalid?

    begin
      @item.save!
      @item.update!(image_url: url_for(@item.image)) unless params[:image].nil?
      flash[:success] = 'Item created'
      render 'items/new'
    rescue StandardError => e
      flash_errors(@item, e, now: true)

      # TODO: stop having to do this
      @locations_layout = location_setup
      @item_type_layout = item_type_setup
      render 'forms/insert_form'
    end
  end

  def purge_items
    purge_date = parse_date_found(params[:purge_date])
    items_to_purge = Item.unclaimed.where('date_found <= ?', purge_date)

    purged_total = items_to_purge.update_all(
      updated_by: current_user.user_name,
      purged: true
    )

    flash[:success] = "#{purged_total} items purged"

    redirect_to admin_items_path
  end

  private

  # datetime_found can be null, and we want to sort those to the end, so we need to use
  # NULLS LAST (see https://www.postgresql.org/docs/current/queries-order.html) and
  # string sort expressions
  def order_by_date_desc(query)
    query.order('date_found DESC', 'datetime_found DESC NULLS LAST', 'created_at DESC')
  end

  def parse_keywords(keyword_param)
    keyword_val = keyword_param&.strip
    keyword_val.blank? ? [] : keyword_val.split
  end

  def date_and_datetime_found_values
    return unless (date_found = parse_date_found(params[:date_found]))
    return date_found unless (hours, minutes = parse_time_found(params[:time_found]))

    # Rails is smart enough to handle DST etc. here
    midnight_on_date_found = date_found.in_time_zone
    datetime_found = midnight_on_date_found + hours.hours + minutes.minutes

    [date_found, datetime_found]
  end

  # Since the parameter doesn't include time zone information, Rails will interpret
  # it as being in the server time zone, usually UTC. This isn't what we want, so
  # we just extract the raw hours and minutes.
  def parse_time_found(dp_param)
    return if dp_param.blank?

    time_found_in_wrong_zone = Time.strptime(dp_param, '%H:%M')
    %i[hour min].map { |a| time_found_in_wrong_zone.send(a) }
  end

  def parse_date_found(df_param)
    return if df_param.blank?

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
