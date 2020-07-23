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
    @roles_layout = [%w[Administrator Administrator]]
    @roles.each do |role|
      @roles_layout.push([role.role_name, role.role_name])
    end
  end

  def create
    @user = User.new
    @user.uid = params[:uid]
    @user.user_name = params[:user_name]
    @user.user_role = params[:user_role]
    @user.user_active = true
    @user.updated_by = cookies[:user_name]
    @user.updated_at = Time.now
    begin
      if @user.valid? && @user.save!
        flash[:success] = "User #{@user.user_name} added"
      else
        flash[:notice] = "UID #{@user.uid} already exists"
      end
    rescue StandardError
      flash[:notice] = "UID #{@user.uid} already exists"
    end
    @users = User.all
    redirect_back(fallback_location: root_path)
  end

  def update
    begin
      active = params[:user_active] == 'true'
      @user = User.find(params[:id])
      @user.update(uid: params[:uid], user_name: params[:user_name], user_role: params[:user_role], user_active: active)
      @users = User.all
    rescue StandardError
      flash[:notice] = "UID #{params[:uid]} already exists"
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
