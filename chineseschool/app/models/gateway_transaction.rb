class GatewayTransaction < ActiveRecord::Base
  
  # Known approval_status from Linkpoint Gateway - APPROVED, DECLINED, DUPLICATE, FRAUD
  APPROVAL_STATUS_APPROVED = 'APPROVED'
  APPROVAL_STATUS_DECLINED = 'DECLINED'
  APPROVAL_STATUS_ERROR = 'ERROR'
  
  belongs_to :registration_payment

  def set_approval_status_based_on_authorize_net_response(authorize_net_response_code)
    # Authorize.Net response code - 1 for approved, 2 for declined, 3 for error, 4 for held for review
    if (authorize_net_response_code == 1)
      self.approval_status = APPROVAL_STATUS_APPROVED
    elsif (authorize_net_response_code == 2)
      self.approval_status = APPROVAL_STATUS_DECLINED
    else
      # set approval status to ERROR if the response code is neither 1 nor 2, which is unexpected
      self.approval_status = APPROVAL_STATUS_ERROR
    end
  end

  def self.find_all_approved_transactions_for(reference_number)
    self.all conditions: ['reference_number = ? AND approval_status = ?', reference_number, APPROVAL_STATUS_APPROVED], order: 'updated_at ASC'
  end
end
