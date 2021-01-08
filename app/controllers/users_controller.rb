class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show; end

  def all
    @users = User.all
  end

  def active
    @users = User.active
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
    @roles = Role.all
    @roles_layout = [%w[Administrator Administrator], %w[Read-only Read-only], %w[Staff Staff]]
  end

  def create
    @user = User.new
    @user.uid = params[:uid]
    @user.user_name = params[:user_name]
    @user.user_role = params[:user_role]
    @user.user_active = true
    @user.updated_by = session[:user_name]
    @user.updated_at = Time.now
    begin
      if @user.valid? && @user.save!
        flash[:success] = "Success: User #{@user.user_name} added"
      else
        flash[:alert] = "Error: UID #{@user.uid} is not numeric"
      end
    rescue StandardError
      flash[:alert] = "Error: UID #{@user.uid} already exists"
    end
    @users = User.all
    redirect_back(fallback_location: root_path)
  end

  def update
    begin
      active = params[:user_active] == 'true'
      @user = User.find(params[:id])
      if @user.update(uid: params[:uid], user_name: params[:user_name], user_role: params[:user_role], user_active: active)
        flash[:success] = "Success: User #{@user.user_name} updated"
      else
        flash[:alert] = "Error: UID #{params[:uid]} is not numeric"
      end
      @users = User.all
    rescue StandardError
      flash[:alert] = "Error: UID #{params[:uid]} already exists"
    end
    redirect_to admin_users_path
  end

  def destroy
    @user = User.delete(params[:id])
    @users = User.all
    redirect_back(fallback_location: root_path)
  end

  def change_status
    @user = User.find(params[:id])
    @user.update(user_active: !@user.user_active)
    @users = User.all
    flash[:success] = "Success: User #{@user.user_name.titleize} status updated!!"
    redirect_back(fallback_location: root_path)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:uid)
  end
end
