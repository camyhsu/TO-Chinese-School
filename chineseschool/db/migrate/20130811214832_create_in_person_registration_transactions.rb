class CreateInPersonRegistrationTransactions < ActiveRecord::Migration
  def self.up
    create_table :in_person_registration_transactions do |t|
      t.integer :registration_payment_id
      t.integer :recorded_by_id
      t.string :payment_method
      t.string :check_number
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :in_person_registration_transactions
  end
end
