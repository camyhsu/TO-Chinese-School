class Admin::RolesController < ApplicationController
  
  def index
    @roles = Role.find(:all)
  end

  def show
    @role = Role.find(params[:id])
  end
end
