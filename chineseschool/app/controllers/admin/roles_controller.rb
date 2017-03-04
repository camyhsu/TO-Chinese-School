class Admin::RolesController < ApplicationController
  
  def index
    @roles = Role.all
  end

  def show
    @role = Role.find params[:id].to_i
  end

  def add_user
    @role = Role.find params[:id].to_i
    @role.users << User.find_by_username(params[:username].strip)
    @role.save!
    redirect_to action: :show, id: @role
  end

  def remove_user
    @role = Role.find params[:id].to_i
    @role.users.delete User.find(params[:user_id].to_i)
    @role.save!
    redirect_to action: :show, id: @role
  end
end
