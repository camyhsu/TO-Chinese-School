class Admin::WithdrawRequestsController < ApplicationController
  def index
    @withdraw_requests = WithdrawRequest.all :conditions => ["school_year_id = ?", SchoolYear.current_school_year.id], :order => 'created_at ASC'
  end

  def show
    @withdraw_request = WithdrawRequest.find params[:id].to_i
  end

  def approve
    withdraw_request = WithdrawRequest.find params[:id].to_i
    withdraw_request.status_code = WithdrawRequest::STATUS_APPROVED
    withdraw_request.status_by_id = @user.person.id
    unless withdraw_request.save_with_side_effects?
      flash[:notice] = "Error happens when save the record. Please try again later or contact us at #{Contacts::WEB_SITE_SUPPORT}."
      redirect_to action: :index
      return
    end

    WithdrawalMailer.student_parent_notification(withdraw_request).deliver
    WithdrawalMailer.accounting_notification(withdraw_request).deliver

    withdraw_request.withdraw_request_details.each do |withdraw_request_detail|
      WithdrawalMailer.pva_notification(withdraw_request_detail.student);
    end

    redirect_to action: :index
  end

  def decline
    withdraw_request = WithdrawRequest.find params[:id].to_i
    withdraw_request.status_code = WithdrawRequest::STATUS_DECLINED
    withdraw_request.status_by_id = @user.person.id
    unless withdraw_request.save
      flash[:notice] = "Error happens when save the record. Please try again later or contact us at #{Contacts::WEB_SITE_SUPPORT}."
      return
    end
    WithdrawalMailer.student_parent_notification(withdraw_request).deliver
    redirect_to action: :index
  end

end
