class Admin::RightsController < ApplicationController

  def index
    @rights = Right.all
  end

end
