class GatewayTransaction < ActiveRecord::Base
  
  # Known approval_status - APPROVED, DECLINED, DUPLICATE, FRAUD
  APPROVAL_STATUS_APPROVED = 'APPROVED'
  
  belongs_to :registration_payment

  def self.find_all_approved_transactions_for(reference_number)
    self.all conditions: ['reference_number = ? AND approval_status = ?', reference_number, APPROVAL_STATUS_APPROVED], order: 'updated_at ASC'
  end
end
