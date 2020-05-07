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

    def destroy
      Role.delete(params[:id])
      @Roles = Role.all
      redirect_back(fallback_location: root_path)
    end
  end