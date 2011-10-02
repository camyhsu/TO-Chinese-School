class Accounting::ManualTransactionsController < ApplicationController
  
  def new
    if request.post?
      # Remove transaction_by from params before creating the new ManualTransaction object due to type incompatibility (string v.s. integer)
      selected_transaction_by_id = params[:manual_transaction].delete :transaction_by
      @manual_transaction = ManualTransaction.new params[:manual_transaction]
      @manual_transaction.transaction_by_id = selected_transaction_by_id.to_i unless selected_transaction_by_id.blank?
      if @manual_transaction.save
        flash[:notice] = 'Manual Transaction added successfully'
        redirect_to :controller => 'registration/people', :action => :show, :id => @manual_transaction.student_id
      end
    else
      @manual_transaction = ManualTransaction.new
      @manual_transaction.student = Person.find_by_id params[:student_id].to_i
      @manual_transaction.transaction_date = PacificDate.today
    end
  end
end
