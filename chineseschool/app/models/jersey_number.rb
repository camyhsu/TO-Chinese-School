class JerseyNumber < ActiveRecord::Base
  
  belongs_to :school_year
  belongs_to :person

  PARENT_PREFIX = '70'

  def jersey_number
    # Starting 2014-2015 school year, track event programs are age-based
    # The prefix is the school age of the student
    # We make the assumption here there there will be 99 or less students per school age
    # and allocating only two digits for the numeric part of the jersey number when printing
    # Similar assumption is in place that there would be 99 or less parents participating in track events
    padded_number = self.number.to_s.rjust 2, '0'
    return padded_number if self.prefix.nil? || self.prefix.size == 0
    self.prefix + padded_number
  end

  def self.create_new_number_for(person)
    new_jersey_number = JerseyNumber.new
    new_jersey_number.person = person
    new_jersey_number.school_year = SchoolYear.current_school_year
    school_age = person.school_age_for SchoolYear.current_school_year
    new_jersey_number.prefix = school_age.to_s.rjust 2, '0'
    new_jersey_number.number = JerseyNumber.find_next_available_number_for new_jersey_number.prefix
    new_jersey_number.save!
    puts new_jersey_number.inspect
  end

  def self.create_new_parent_number_for(person)
    # Parent jersey numbers need special treatment because we don't have the age data for parent
    # It uses a per-determined prefix
    new_jersey_number = JerseyNumber.new
    new_jersey_number.person = person
    new_jersey_number.school_year = SchoolYear.current_school_year
    new_jersey_number.prefix = PARENT_PREFIX
    new_jersey_number.number = JerseyNumber.find_next_available_number_for new_jersey_number.prefix
    new_jersey_number.save!
    puts new_jersey_number.inspect
  end

  
  def self.find_jersey_number_for(person, school_year=SchoolYear.current_school_year)
    existing_jersey_number = self.first :conditions => ['person_id = ? AND school_year_id = ?', person.id, school_year.id]
    return '' if existing_jersey_number.nil?
    existing_jersey_number.jersey_number
  end

  def self.find_next_available_number_for(prefix)
    largest_jersey_number_assigned = self.first :conditions => { :school_year_id => SchoolYear.current_school_year.id, :prefix => prefix }, :order => 'number DESC'
    if largest_jersey_number_assigned.nil?
      1
    else
      largest_jersey_number_assigned.number + 1
    end
  end
end
