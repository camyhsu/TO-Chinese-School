class SchoolYearsAddProrateSchedule < ActiveRecord::Migration
  def self.up
    add_column :school_years, :registration_start_date, :date
    add_column :school_years, :registration_75_percent_date, :date
    add_column :school_years, :registration_50_percent_date, :date
    add_column :school_years, :registration_end_date, :date
    add_column :school_years, :refund_75_percent_date, :date
    add_column :school_years, :refund_50_percent_date, :date
    add_column :school_years, :refund_25_percent_date, :date
    add_column :school_years, :refund_end_date, :date
  end

  def self.down
    remove_column :school_years, :registration_start_date
    remove_column :school_years, :registration_75_percent_date
    remove_column :school_years, :registration_50_percent_date
    remove_column :school_years, :registration_end_date
    remove_column :school_years, :refund_75_percent_date
    remove_column :school_years, :refund_50_percent_date
    remove_column :school_years, :refund_25_percent_date
    remove_column :school_years, :refund_end_date
  end
end
