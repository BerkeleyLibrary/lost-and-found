class ItemTypesController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  # TODO: clean this up further
  # rubocop:disable Metrics/MethodLength
  def create
    item_type = ItemType.new(
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      type_name: params[:type_name].downcase,
      type_active: true,
      updated_by: current_user.user_name
    )

    begin
      item_type.save!
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      flash[:success] = "Item type #{item_type.type_name.titleize} added"
    rescue StandardError => e
      flash_errors(item_type, e)
    end

    redirect_to(admin_item_types_path)
  end
  # rubocop:enable Metrics/MethodLength

  def edit
    @item_type = ItemType.find(params[:id])
  end

  # TODO: clean this up further
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    item_type = ItemType.find(params[:id])
    begin
      item_type.update!(
        type_name: params[:type_name].downcase,
        type_active: (params[:type_active] == 'true'),
        updated_by: current_user.user_name
      )
      # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
      flash[:success] = "Item type #{item_type.type_name.titleize} updated"
    rescue StandardError => e
      flash_errors(item_type, e)
    end

    redirect_to admin_item_types_path
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def change_status
    item_type = ItemType.find(params[:id])
    item_type.update!(
      type_active: !item_type.type_active,
      updated_by: current_user.user_name
    )

    # TODO: enforce case-insensitive uniqueness w/o mangling user-entered names
    flash[:success] = "Item type #{item_type.type_name.titleize} #{item_type.type_active? ? 'activated' : 'deactivated'}"
    redirect_to admin_item_types_path
  end
end
