class Admin::WithdrawRequestsController < ApplicationController
  def index
    @withdraw_requests = WithdrawRequest.all :conditions => ["school_year_id = ?", SchoolYear.current_school_year.id], :order => 'created_at ASC'
  end
end
