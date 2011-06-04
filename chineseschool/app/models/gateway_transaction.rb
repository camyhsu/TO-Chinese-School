class GatewayTransaction < ActiveRecord::Base
  
  # Known approval_status - APPROVED, DECLINED, DUPLICATE, FRAUD
  APPROVAL_STATUS_APPROVED = 'APPROVED'
  
  belongs_to :registration_payment
end
