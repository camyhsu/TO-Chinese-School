class ReceiptMailer < ActionMailer::Base

  def payment_confirmation(gateway_transaction, registration_payment)
    subject    'Thousand Oaks Chinese School - Payment Confirmation'
    recipients registration_payment.paid_by.personal_email_address
    from       Contacts::WEB_SITE_SUPPORT
    sent_on    Time.now
    content_type 'text/html'

    body       :registration_payment => registration_payment, :gateway_transaction => gateway_transaction
  end

  def text_book_notification(students)
    subject    'TOCS - text books for new students'
    recipients Contacts::TEXT_BOOK_MANAGER
    from       Contacts::WEB_SITE_SUPPORT
    sent_on    Time.now

    body       :students => students
  end
end
