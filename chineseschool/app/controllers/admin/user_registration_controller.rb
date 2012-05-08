class Admin::UserRegistrationController < ApplicationController

  def invite
    if request.post?
      person_id = params[:person_id].to_i
      person = Person.find_by_id person_id
      flash.now[:notice] = "Person with id => #{person_id} not found" and return if person.nil?
      flash.now[:notice] = "Person with id => #{person_id} already has an account" and return unless person.user.nil?
      send_invitation_to person, params[:email_destination]
      flash.now[:notice] = "Invitation sent to Person id => #{person_id}, name => #{person.name}, " +
          "email_destination => #{params[:email_destination]}"
    end
  end

  def invite_parents_by_school_class
    if request.post?
      unless params[:parent_one].nil?
        params[:parent_one].each_key do |family_id|
          family = Family.find_by_id family_id.to_i
          send_invitation_to family.parent_one, family.address.email
        end
      end
      unless params[:parent_two].nil?
        params[:parent_two].each_key do |family_id|
          family = Family.find_by_id family_id.to_i
          send_invitation_to family.parent_two, family.address.email
        end
      end
    end
    @students = SchoolClass.find_by_id(params[:id].to_i).students
  end

  private

  def send_invitation_to(person, email_destination)
    email = SigninMailer.create_account_invitation person, email_destination
    SigninMailer.deliver email
  end
end
