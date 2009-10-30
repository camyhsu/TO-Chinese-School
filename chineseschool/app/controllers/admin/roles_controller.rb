class Admin::RolesController < ApplicationController

  def index
    @roles = Role.find(:all)
  end

  def new
    @role = Role.new
  end

end
