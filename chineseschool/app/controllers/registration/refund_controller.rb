class Registration::RefundController < ApplicationController

  def refund_full_registration_payment
    if request.post?
      gateway_transactions = GatewayTransaction.find_all_approved_transactions_for params[:reference_number]
      if gateway_transactions.nil? or gateway_transactions.empty?
        flash.now[:notice] = "Gateway Transaction with reference number => #{params[:reference_number]} not found" and return
      end
      
      # Sanity checks
      expected_paid_by_id = params[:paid_by].to_i
      if gateway_transactions.any? { |gateway_transaction| gateway_transaction.registration_payment.paid_by_id != expected_paid_by_id }
        flash.now[:notice] = "One of Registration Payments is not paid by given person id => #{params[:paid_by]}" and return
      end

      # Make sure the remaining total is still positive for refund
      remaining_total_in_cents = 0
      gateway_transactions.each do |gateway_transaction|
        if gateway_transaction.credit?
          remaining_total_in_cents -= gateway_transaction.amount_in_cents
        else
          remaining_total_in_cents += gateway_transaction.amount_in_cents
        end
      end
      unless remaining_total_in_cents > 0
        flash.now[:notice] = "Remaining total in cents => #{remaining_total_in_cents} -- nothing left to refund" and return
      end
      
      # After all these checks, we would only process the case where there was only one original payment for full refund
      if gateway_transactions.size > 1
        flash.now[:notice] = "Full refund can only be processed if there were no partial refund before" and return
      end
      gateway_transaction_to_refund = gateway_transactions[0]

      # Create new registration payment representing the refund transaction
      refund_registration_payment = create_and_save_refund_registration_payment gateway_transaction_to_refund.registration_payment

      # Another sanity check
      if refund_registration_payment.grand_total_in_cents != - gateway_transaction_to_refund.registration_payment.grand_total_in_cents
        flash.now[:notice] = "Something went wrong -- refund total => #{refund_registration_payment.grand_total_in_cents} should equal charge total => #{gateway_transaction_to_refund.registration_payment.grand_total_in_cents}" and return
      end

      # Contact gateway for the refund
      refund_gateway_transaction = create_and_save_initial_refund_gateway_transaction refund_registration_payment, gateway_transaction_to_refund
      begin
        response = ::LINKPOINT_GATEWAY.refund(refund_gateway_transaction.amount_in_cents, gateway_transaction_to_refund.id)
        save_refund_gateway_response refund_gateway_transaction, response
        #save_fake_response_for_test refund_gateway_transaction
      rescue => e
        refund_gateway_transaction.error_message = e.inspect
        refund_gateway_transaction.save!
        flash.now[:notice] = "Error occurred when processing refund -- refund gateway transaction id => #{refund_gateway_transaction.id}" and return
      end

      if GatewayTransaction::APPROVAL_STATUS_APPROVED == refund_gateway_transaction.approval_status
        refund_registration_payment.paid = true
        refund_registration_payment.save!
        flash.now[:notice] = "Refund Successful"
      else
        flash.now[:notice] = "Refund DECLINED by bank -- refund gateway transaction id => #{refund_gateway_transaction.id}"
      end
    end
  end

  private

  def create_and_save_refund_registration_payment(registration_payment_to_refund)
    refund_registration_payment = RegistrationPayment.new
    refund_registration_payment.school_year = registration_payment_to_refund.school_year
    refund_registration_payment.paid_by = registration_payment_to_refund.paid_by
    registration_payment_to_refund.student_fee_payments.each do |student_fee_payment_to_refund|
      refund_student_fee_payment = StudentFeePayment.new
      refund_student_fee_payment.student = student_fee_payment_to_refund.student
      refund_student_fee_payment.registration_fee_in_cents = - student_fee_payment_to_refund.registration_fee_in_cents
      refund_student_fee_payment.tuition_in_cents = - student_fee_payment_to_refund.tuition_in_cents
      refund_student_fee_payment.book_charge_in_cents = - student_fee_payment_to_refund.book_charge_in_cents
      refund_student_fee_payment.pre_registration = student_fee_payment_to_refund.pre_registration
      refund_student_fee_payment.multiple_child_discount = student_fee_payment_to_refund.multiple_child_discount
      refund_student_fee_payment.pre_k_discount = student_fee_payment_to_refund.pre_k_discount
      refund_student_fee_payment.registration_payment = refund_registration_payment
      refund_registration_payment.student_fee_payments << refund_student_fee_payment
    end
    refund_registration_payment.pva_due_in_cents = - registration_payment_to_refund.pva_due_in_cents
    refund_registration_payment.ccca_due_in_cents = - registration_payment_to_refund.ccca_due_in_cents
    refund_registration_payment.calculate_grand_total
    refund_registration_payment.save!
    refund_registration_payment
  end

  def create_and_save_initial_refund_gateway_transaction(refund_registration_payment, gateway_transaction_to_refund)
    refund_gateway_transaction = GatewayTransaction.new
    refund_gateway_transaction.registration_payment = refund_registration_payment
    refund_gateway_transaction.amount_in_cents = - refund_registration_payment.grand_total_in_cents
    refund_gateway_transaction.credit_card_type = gateway_transaction_to_refund.credit_card_type
    refund_gateway_transaction.credit_card_last_digits = gateway_transaction_to_refund.credit_card_last_digits
    refund_gateway_transaction.reference_number = gateway_transaction_to_refund.reference_number
    refund_gateway_transaction.credit = true
    refund_gateway_transaction.save!
    refund_gateway_transaction
  end

  def save_refund_gateway_response(refund_gateway_transaction, response)
    refund_gateway_transaction.approval_status = response.params['approved']
    refund_gateway_transaction.response_dump = response.inspect
    unless response.success?
      refund_gateway_transaction.error_message = response.params['error']
    end
    refund_gateway_transaction.save!
  end

  def save_fake_response_for_test(refund_gateway_transaction)
    refund_gateway_transaction.approval_status = GatewayTransaction::APPROVAL_STATUS_APPROVED
    refund_gateway_transaction.response_dump = 'response.inspect'
    refund_gateway_transaction.save!
  end
end
