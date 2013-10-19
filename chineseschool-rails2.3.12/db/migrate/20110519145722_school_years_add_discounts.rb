class SchoolYearsAddDiscounts < ActiveRecord::Migration
  def self.up
    add_column :school_years, :pre_registration_end_date, :date
    add_column :school_years, :pre_registration_tuition_in_cents, :integer, :null => false, :default => 38000
    add_column :school_years, :tuition_discount_for_three_or_more_child_in_cents, :integer, :null => false, :default => 3800
    add_column :school_years, :tuition_discount_for_pre_k_in_cents, :integer, :null => false, :default => 4000

    year_2008 = SchoolYear.find_by_name '2008-2009'
    year_2008.pre_registration_end_date = Date.parse '2008-08-01'
    year_2008.save!
    year_2009 = SchoolYear.find_by_name '2009-2010'
    year_2009.pre_registration_end_date = Date.parse '2009-08-01'
    year_2009.save!
    year_2010 = SchoolYear.find_by_name '2010-2011'
    year_2010.pre_registration_end_date = Date.parse '2010-08-01'
    year_2010.save!
    year_2011 = SchoolYear.find_by_name '2011-2012'
    year_2011.pre_registration_end_date = Date.parse '2011-08-01'
    year_2011.save!
  end

  def self.down
    remove_column :school_years, :tuition_discount_for_pre_k_in_cents
    remove_column :school_years, :tuition_discount_for_three_or_more_child_in_cents
    remove_column :school_years, :pre_registration_tuition_in_cents
    remove_column :school_years, :pre_registration_end_date
  end
end
