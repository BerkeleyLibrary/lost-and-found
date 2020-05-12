class RolesController < ApplicationController

    def all
      @Roles = Role.all
    end

    def create
      @Role = Role.new()
      @Role.role_name = params[:role_name]
      @Role.role_level = params[:role_level]

      if @Role.save!
        @Roles = Role.all
        redirect_back(fallback_location: root_path)
      else
        @Roles = Role.all
        redirect_back(fallback_location: root_path)
      end
    end

    def edit
      @role = Role.find(params[:id])
    end

    def update
      @role = Role.find(params[:id])
      @role.update(role_name: params[:role_name], role_level: params[:role_level])
      @roles = Role.all
      redirect_to admin_path
    end

    def destroy
      Role.delete(params[:id])
      @Roles = Role.all
      redirect_back(fallback_location: root_path)
    end
  end