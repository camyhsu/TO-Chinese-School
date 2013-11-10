class SigninMailer < ActionMailer::Base
  default from: Contacts::WEB_SITE_SUPPORT
  
  def account_invitation(person, email_destination)
    @person_to_invite = person
    @invitation_url = invitation_url_for person

    mail to: email_destination, subject: 'Thousand Oaks Chinese School - Account Invitation'
  end

  def forgot_password(person, email_destination)
    @person = person
    @token_url = forgot_password_url_for person

    mail to: email_destination, subject: 'Thousand Oaks Chinese School - Password Reset'
  end

  
  private

  def invitation_url_for(person)
    timed_token = TimedToken.new
    timed_token.generate_token
    timed_token.person = person
    timed_token.expiration = Time.now.advance :days => 3
    timed_token.save!
    "https://www.to-cs.org/chineseschool/signin/register_with_invitation/#{timed_token.token}"
  end

  def forgot_password_url_for(person)
    timed_token = TimedToken.new
    timed_token.generate_token
    timed_token.person = person
    timed_token.expiration = Time.now.advance :hours => 6
    timed_token.save!
    "https://www.to-cs.org/chineseschool/signin/reset_password/#{timed_token.token}"
  end
end
