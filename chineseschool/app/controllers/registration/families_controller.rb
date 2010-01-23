class Registration::FamiliesController < ApplicationController

  def show
    @family = Family.find_by_id(params[:id].to_i)
  end

end
