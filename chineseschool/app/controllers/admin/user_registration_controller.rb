class Admin::UserRegistrationController < ApplicationController

  def invite
    if request.post? || request.put?
      person_id = params[:person_id].to_i
      begin
        person = Person.find person_id
      rescue ActiveRecord::RecordNotFound
        person = nil
      end
      flash.now[:notice] = "Person with id => #{person_id} not found" and return if person.nil?
      flash.now[:notice] = "Person with id => #{person_id} already has an account" and return unless person.user.nil?
      email_destination = params[:email_destination]
      flash.now[:notice] = 'Email destination can not be empty' and return if email_destination.empty?
      SigninMailer.account_invitation(person, email_destination).deliver
      flash.now[:notice] = "Invitation sent to Person id => #{person_id}, name => #{person.name}, email_destination => #{email_destination}"
    end
  end
end
