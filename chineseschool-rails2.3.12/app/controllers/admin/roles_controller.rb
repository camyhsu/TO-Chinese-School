class Admin::RolesController < ApplicationController
  
  def index
    @roles = Role.find(:all)
  end

  def show
    @role = Role.find_by_id params[:id].to_i
  end

  def add_user
    @role = Role.find_by_id params[:id].to_i
    @role.users << User.find_by_id(params[:user_id].to_i)
    @role.save!
    redirect_to :action => :show, :id => @role.id
  end

  def remove_user
    @role = Role.find_by_id params[:id].to_i
    @role.users.delete User.find_by_id(params[:user_id].to_i)
    @role.save!
    redirect_to :action => :show, :id => @role.id
  end
end
