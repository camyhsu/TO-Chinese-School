class Student::RegistrationController < ApplicationController

  before_filter :action_authorized?

  def display_registration_options
    registration_school_year = SchoolYear.find_by_id params[:id].to_i
    @possible_students = []
    @user.person.families.each do |family|
      @possible_students += family.children
    end
    @available_elective_classes = SchoolClass.find_available_elective_classes_for_registration registration_school_year
  end
  
  def display_pricing
    
  end

  private

  def action_authorized?
    true
  end
end
