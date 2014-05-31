class ReceiptMailer < ActionMailer::Base
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
end
