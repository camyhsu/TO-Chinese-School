class SchoolYearsAddFees < ActiveRecord::Migration
  def self.up
    add_column :school_years, :registration_fee_in_cents, :integer, :null => false, :default => 2000
    add_column :school_years, :tuition_in_cents, :integer, :null => false, :default => 38000
    add_column :school_years, :book_charge_in_cents, :integer, :null => false, :default => 2000
    add_column :school_years, :pva_membership_due_in_cents, :integer, :null => false, :default => 1500
    add_column :school_years, :ccca_membership_due_in_cents, :integer, :null => false, :default => 2000
  end

  def self.down
    remove_column :school_years, :registration_fee_in_cents
    remove_column :school_years, :tuition_in_cents
    remove_column :school_years, :book_charge_in_cents
    remove_column :school_years, :pva_membership_due_in_cents
    remove_column :school_years, :ccca_membership_due_in_cents
  end
end
