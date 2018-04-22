class Admin::StaffAssignmentsController < ApplicationController

  def index
    # we only have staff assignment data starting school year 2016-2017
    @school_years = SchoolYear.where('id > 8')
  end

  def show
    @school_year = SchoolYear.find params[:id].to_i
    @staff_assignments = StaffAssignment.find_all_by_school_year_id @school_year.id
  end
end
