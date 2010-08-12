class Admin::RolesController < ApplicationController

  verify :only => :create, :method => :post, :add_flash => { :notice => 'Illegal GET' }, :redirect_to => { :action => 'index' }

  def index
    @roles = Role.find(:all)
  end

#  def new
#    @role = Role.new
#  end
#
#  def create
#    @role = Role.new(params[:role])
#    if @role.save
#      redirect_to :action => 'index'
#    else
#      render :action => 'new'
#    end
#  end

  def show
    @role = Role.find(params[:id])
  end
end
