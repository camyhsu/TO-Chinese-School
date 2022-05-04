class AddElectiveClassFeeInCentsToWithdrawRequestDetails < ActiveRecord::Migration
  def change
    add_column :withdraw_request_details, :elective_class_fee_in_cents, :integer,  null: false, default: 0
  end
end
