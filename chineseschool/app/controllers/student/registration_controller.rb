class Student::RegistrationController < ApplicationController

  before_filter :action_authorized?

  def display_registration_options

  end
  
  def select_class_assignments
    
  end

  private

  def action_authorized?
    true
  end
end
