class UsersController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  def edit
    @user = User.find(params[:id])
  end

  # TODO: clean this up further
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    user = User.new(
      uid: params[:uid],
      user_name: params[:user_name],
      user_role: params[:user_role],
      user_active: true,
      updated_by: current_user.user_name
    )

    begin
      user.save!
      flash[:success] = "User #{user.user_name} added"
      redirect_to admin_users_path
    rescue StandardError => e
      flash_errors(user, e)
      @active_users = User.active
      @inactive_users = User.inactive
      render 'home/admin_users'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # TODO: clean this up further
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    @user = User.find(params[:id])

    begin
      # TODO: just use strong parameters
      @user.update!(
        uid: params[:uid],
        user_name: params[:user_name],
        user_role: params[:user_role],
        updated_by: current_user.user_name,
        user_active: (params[:user_active] == '1')
      )
      flash[:success] = "User #{@user.user_name} updated"
      redirect_to admin_users_path
    rescue StandardError => e
      flash_errors(@user, e)
      render 'users/edit'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def change_status
    user = User.find(params[:id])
    user.update(user_active: !user.user_active, updated_by: current_user.user_name)
    flash[:success] = "User #{user.user_name} #{user.user_active? ? 'activated' : 'deactivated'}"
    redirect_to admin_users_path
  end
end
