class SchoolYearsAddDiscounts < ActiveRecord::Migration
  def self.up
    add_column :school_years, :pre_registration_end_date, :date
    add_column :school_years, :pre_registration_tuition_in_cents, :integer, :null => false, :default => 38000
    add_column :school_years, :tuition_discount_for_three_or_more_child_in_cents, :integer, :null => false, :default => 3800
    add_column :school_years, :tuition_discount_for_pre_k_in_cents, :integer, :null => false, :default => 4000
  end

  def self.down
    remove_column :school_years, :tuition_discount_for_pre_k_in_cents
    remove_column :school_years, :tuition_discount_for_three_or_more_child_in_cents
    remove_column :school_years, :pre_registration_tuition_in_cents
    remove_column :school_years, :pre_registration_end_date
  end
end
