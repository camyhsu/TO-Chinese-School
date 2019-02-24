class AddCancelledToWithdrawRequests < ActiveRecord::Migration
  def change
    add_column :withdraw_requests, :cancelled, :boolean
  end
end
