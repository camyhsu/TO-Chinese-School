class WithdrawalMailer < ActionMailer::Base
  default from: Contacts::REGISTRATION_CONTACT

  def instructor_notification(student, school_class)
    @student = student
    @school_class = school_class
    mail to: school_class.current_primary_instructor.personal_email_address, subject: 'Thousand Oaks Chinese School - Student Withdrawal'
  end

  def student_parent_notification(withdraw_request)
    @withdraw_request = withdraw_request
    mail to: withdraw_request.request_by.personal_email_address, subject: 'Thousand Oaks Chinese School - Student Withdrawal'
  end

  def registration_notification(withdraw_request)
    @withdraw_request = withdraw_request
    mail to: Contacts::REGISTRATION_CONTACT, subject: 'Thousand Oaks Chinese School - Student Withdrawal'
  end

  def accounting_notification(withdraw_request)
    @withdraw_request = withdraw_request
    mail to: Contacts::ACCOUNTING_CONTACT, subject: 'Thousand Oaks Chinese School - Student Withdrawal'
  end

  def pva_notification(student)
    @student = student
    mail to: Contacts::PVA_CONTACT, subject: 'Thousand Oaks Chinese School - Student Withdrawal'
  end

end
