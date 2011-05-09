class Student::RegistrationController < ApplicationController

  before_filter :action_authorized?

  private

  def action_authorized?
    true
  end
end
