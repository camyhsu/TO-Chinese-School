class SigninMailer < ActionMailer::Base
  
  def registration_invitation(person, email_destination)
    subject    'Thousand Oaks Chinese School - Registration Invitation'
    recipients email_destination
    from       'engineering@to-cs.org'
    sent_on    Time.now
    
    body       :person_to_invite => person, :invitation_url => generate_invitation_url(person)
  end

  def forgot_password(person, email_destination)
    subject    'Thousand Oaks Chinese School - Password Reset'
    recipients email_destination
    from       'engineering@to-cs.org'
    sent_on    Time.now

    body       :person => person, :token_url => generate_forgot_password_url(person)
  end

  
  private

  def generate_invitation_url(person)
    timed_token = TimedToken.new
    timed_token.generate_token
    timed_token.person = person
    timed_token.expiration = Time.now.advance :days => 2
    timed_token.save!
    "https://www.to-cs.org/chineseschool/signin/register_with_invitation/#{timed_token.token}"
  end

  def generate_forgot_password_url(person)
    timed_token = TimedToken.new
    timed_token.generate_token
    timed_token.person = person
    timed_token.expiration = Time.now.advance :hours => 6
    timed_token.save!
    "https://www.to-cs.org/chineseschool/signin/reset_password/#{timed_token.token}"
  end
end
