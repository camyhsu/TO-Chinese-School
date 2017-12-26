class OpsMailer < ActionMailer::Base
  default from: Contacts::WEB_SITE_SUPPORT

  def credit_card_transaction_error_alert(gateway_transaction)
    @gateway_transaction = gateway_transaction
    mail to: Contacts::WEB_SITE_SUPPORT, subject: 'Thousand Oaks Chinese School - Credit Card Processing Error'
  end
end