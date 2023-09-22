class AddElectiveClassOnlyToWithdrawRequestDetails < ActiveRecord::Migration
  def change
    add_column :withdraw_request_details, :elective_class_only, :string, default: 'N'
  end
end
