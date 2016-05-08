class Admin::StaffAssignmentsController < ApplicationController

  def index
    @school_years = SchoolYear.all
  end

  def show
    @school_year = SchoolYear.find params[:id].to_i
    @staff_assignments = StaffAssignment.find_all_by_school_year_id @school_year.id
  end
end
