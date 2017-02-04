class ReceiptMailer < ActionMailer::Base
  add_template_helper Student::RegistrationHelper
  default from: Contacts::REGISTRATION_CONTACT

  def payment_confirmation(gateway_transaction, registration_payment)
    @registration_payment = registration_payment
    @gateway_transaction = gateway_transaction
    mail to: registration_payment.paid_by.personal_email_address, subject: 'Thousand Oaks Chinese School - Payment Confirmation'
  end

  def text_book_notification(students)
    @students = students
    mail to: Contacts::TEXT_BOOK_MANAGER, subject: 'TOCS - text books for new students'
  end

  def registration_staff_notification(students)
    @students = students
    mail to: Contacts::REGISTRATION_CONTACT, subject: 'TOCS - new students registered'
  end
end
