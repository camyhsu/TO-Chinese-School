class SchoolYearsAddPreviousSchoolYearId < ActiveRecord::Migration
  def self.up
    add_column :school_years, :previous_school_year_id, :integer

    year_2008 = SchoolYear.find_by_name '2008-2009'
    year_2009 = SchoolYear.find_by_name '2009-2010'
    year_2009.previous_school_year_id = year_2008.id
    year_2009.save!
    year_2010 = SchoolYear.find_by_name '2010-2011'
    year_2010.previous_school_year_id = year_2009.id
    year_2010.save!
    year_2011 = SchoolYear.find_by_name '2011-2012'
    year_2011.previous_school_year_id = year_2010.id
    year_2011.save!
  end

  def self.down
    remove_column :school_years, :previous_school_year_id
  end
end
