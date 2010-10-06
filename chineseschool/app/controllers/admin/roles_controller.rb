class Admin::RolesController < ApplicationController
  
  def index
    @roles = Role.find(:all)
  end

  def show
    @role = Role.find_by_id params[:id].to_i
  end
end
