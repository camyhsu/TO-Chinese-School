class Admin::RightsController < ApplicationController

  def index
    @rights = Right.find(:all)
  end

end
