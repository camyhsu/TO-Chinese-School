class JerseyNumber < ActiveRecord::Base
  
  belongs_to :school_year
  belongs_to :person
  
  def self.find_jersey_number_for(person, school_year=SchoolYear.current_school_year)
    existing_jersey_number = self.first :conditions => ['person_id = ? AND school_year_id = ?', person.id, school_year.id]
    if existing_jersey_number.nil?
      new_jersey_number = JerseyNumber.new
      new_jersey_number.person = person
      new_jersey_number.school_year = school_year
      new_jersey_number.number = self.find_next_available_number_for school_year
      new_jersey_number.save!
      new_jersey_number.number
    else
      existing_jersey_number.number
    end
  end
  
  def self.find_next_available_number_for(school_year)
    largest_jersey_number_assigned = self.first :conditions => ['school_year_id = ?', school_year.id], :order => 'number DESC'
    return 1 if largest_jersey_number_assigned.nil?
    largest_jersey_number_assigned.number + 1
  end
end
