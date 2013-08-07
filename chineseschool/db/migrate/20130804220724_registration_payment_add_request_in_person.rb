class RegistrationPaymentAddRequestInPerson < ActiveRecord::Migration
  def self.up
    add_column :registration_payments, :request_in_person, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :registration_payments, :request_in_person
  end
end
