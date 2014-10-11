class WithdrawalMailer < ActionMailer::Base
  default from: Contacts::REGISTRATION_CONTACT

  def instructor_notification(student, school_class)
    @student = student
    @school_class = school_class
    mail to: school_class.current_primary_instructor.personal_email_address, subject: 'Thousand Oaks Chinese School - Student Withdrawal'
  end
end
