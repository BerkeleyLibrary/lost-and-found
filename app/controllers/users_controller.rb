class UsersController < ApplicationController
    def index
      @users = User.all
    end

    def show
    end

    def all
      @users = User.all
    end

    def active
      @users = User.active
    end

    def new
      @User = User.new
    end

    def edit
      @user = User.find(params[:id])
      @roles = Role.all
      @roles_layout = [["Administrator","Administrator"]]
      @roles.each do |role|
        @roles_layout.push([role.role_name, role.role_name])
      end
    end

    def create
      @user = User.new()
      @user.uid = params[:uid];
      @user.user_name = params[:user_name]
      @user.user_role = params[:user_role];
      @user.user_active = true;

      begin
        if @user.valid? && @user.save!
          @users = User.all
          redirect_back(fallback_location: root_path)
        else
           @users = User.all
           redirect_back(fallback_location: root_path)
        end
      rescue Exception => e
        p e
        redirect_back(fallback_location: root_path)
      end
    end

    def update
      active = params[:user_active] == "true"
      @user = User.find(params[:id])
      @user.update(uid: params[:uid], user_name: params[:user_name],user_role: params[:user_role], user_active: active)
      @users = User.all
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