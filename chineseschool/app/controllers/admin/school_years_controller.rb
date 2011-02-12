class Admin::SchoolYearsController < ApplicationController

  def index
    @school_years = SchoolYear.all
  end

  def show
    @school_year = SchoolYear.find_by_id params[:id].to_i
  end
end
