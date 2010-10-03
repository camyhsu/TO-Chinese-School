class Admin::UserRegistrationController < ApplicationController

  def invite
    if request.post?
      person_id = params[:person_id].to_i
      person = Person.find_by_id person_id
      flash.now[:notice] = "Person with id => #{person_id} not found" and return if person.nil?
      flash.now[:notice] = "Person with id => #{person_id} already has an account" and return unless person.user.nil?
      email = SigninMailer.create_registration_invitation person, params[:email_destination], generate_invitation_url(person)
      SigninMailer.deliver email
      flash.now[:notice] = "Invitation sent to Person id => #{person_id}, name => #{person.name}, " +
          "email_destination => #{params[:email_destination]}"
    end
  end
  

  private

  def generate_invitation_url(person_to_invite)
    timed_token = TimedToken.new
    timed_token.generate_token
    timed_token.person = person_to_invite
    timed_token.expiration = Time.now.advance :days => 2
    timed_token.save!
    "https://www.to-cs.org/chineseschool/signin/register_with_invitation/#{timed_token.token}"
  end
end
