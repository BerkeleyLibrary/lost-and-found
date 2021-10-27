class UsersController < ApplicationController
  before_action :logout_if_expired!
  before_action :require_admin!

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new
    @user.uid = params[:uid]
    @user.user_name = params[:user_name]
    @user.user_role = params[:user_role]
    @user.user_active = true
    @user.updated_by = current_user.user_name
    @user.updated_at = Time.now
    begin
      if @user.valid? && @user.save!
        flash[:success] = "Success: User #{@user.user_name} added"
      else
        flash[:alert] = "Error: UID #{params[:uid].inspect} is not numeric"
      end
    rescue StandardError
      flash[:alert] = "Error: UID already exists"
    end
    @users = User.all
    redirect_back(fallback_location: login_path)
  end

  def update
    begin
      active = params[:user_active] == 'true'
      @user = User.find(params[:id])
      # TODO: just use strong parameters
      if @user.update(
        uid: params[:uid],
        user_name: params[:user_name],
        user_role: params[:user_role],
        updated_by: current_user.user_name,
        user_active: active
      )
        flash[:success] = "Success: User #{@user.user_name} updated"
      else
        flash[:alert] = "Error: UID #{params[:uid].inspect} is not numeric"
      end
      @users = User.all
    rescue StandardError
      flash[:alert] = "Error: UID #{params[:uid]} already exists"
    end
    redirect_to admin_users_path
  end

  def change_status
    @user = User.find(params[:id])
    @user.update(user_active: !@user.user_active, updated_by: current_user.user_name)
    @users = User.all
    flash[:success] = "Success: User #{@user.user_name.titleize} status updated!"
    redirect_back(fallback_location: login_path)
  end
end
