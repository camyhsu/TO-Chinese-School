class SchoolYearsAddAgeCutoffMonth < ActiveRecord::Migration
  def self.up
    add_column :school_years, :age_cutoff_month, :integer
  end

  def self.down
    remove_column :school_years, :age_cutoff_month
  end
end
