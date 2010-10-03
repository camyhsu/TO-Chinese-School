class SigninMailer < ActionMailer::Base
  

  def registration_invitation(person_to_invite, email_destination, invitation_url)
    subject    'Thousand Oaks Chinese School - Registration Invitation'
    recipients email_destination
    from       'engineering@to-cs.org'
    sent_on    Time.now
    
    body       :person_to_invite => person_to_invite, :invitation_url => invitation_url
  end

end
