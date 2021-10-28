class UsersController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(
      uid: params[:uid],
      user_name: params[:user_name],
      user_role: params[:user_role],
      user_active: true,
      updated_by: current_user.user_name
    )

    begin
      @user.save!
      flash[:success] = "Success: User #{@user.user_name} added"
    rescue StandardError => e
      flash_errors(@user, e)
    end
    @users = User.all
    redirect_to admin_users_path
  end

  def update
    active = params[:user_active] == 'true'
    @user = User.find(params[:id])

    begin
      # TODO: just use strong parameters
      @user.update!(
        uid: params[:uid],
        user_name: params[:user_name],
        user_role: params[:user_role],
        updated_by: current_user.user_name,
        user_active: active
      )
      flash[:success] = "Success: User #{@user.user_name} updated"
      redirect_to admin_users_path
    rescue StandardError => e
      flash_errors(@user, e)
      redirect_to edit_user_path(id: @user.id)
    ensure
      @users = User.all
    end
  end

  def change_status
    @user = User.find(params[:id])
    @user.update(user_active: !@user.user_active, updated_by: current_user.user_name)
    @users = User.all
    flash[:success] = "Success: User #{@user.user_name.titleize} status updated!"
    redirect_to admin_users_path
  end
end
