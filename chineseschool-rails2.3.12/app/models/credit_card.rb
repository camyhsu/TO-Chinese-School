class CreditCard < ActiveMerchant::Billing::CreditCard

  ALLOWED_CREDIT_CARD_TYPE = ['visa', 'master', 'discover']

  # Override validation methods to meet Chinese School requirements
  
  def validate_essential_attributes #:nodoc:
    if @month.to_i.zero? || @year.to_i.zero?
      errors.add :month, "is required"  if @month.to_i.zero?
      errors.add :year,  "is required"  if @year.to_i.zero?
    else
      errors.add :month,      "is not a valid month" unless valid_month?(@month)
      errors.add 'card',      "has expired"              if expired?
      errors.add :year,       "is not a valid year"  unless valid_expiry_year?(@year)
    end
  end

  def validate_card_type #:nodoc:
    errors.add "#{type}", "is not accepted by Chinese School" unless type.blank? || ALLOWED_CREDIT_CARD_TYPE.include?(type)
  end

  def validate_card_number #:nodoc:
    if number.blank?
      errors.add 'Card Number', "is required"
    elsif !CreditCard.valid_number?(number)
      errors.add 'Card Number', "is not a valid credit card number"
    end
  end
  
  def validate_verification_value #:nodoc:
    errors.add 'Card Code', "is required" unless verification_value?
  end
end
