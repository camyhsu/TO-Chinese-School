class JerseyNumber < ActiveRecord::Base
  
  belongs_to :school_year
  belongs_to :person

  def jersey_number
    padded_number = self.number.to_s.rjust 3, '0'
    return padded_number if self.prefix.nil? || self.prefix.size == 0
    self.prefix + padded_number
  end
  
  def self.create_jersey_number_for_student(person, prefix, next_number)
    existing_jersey_number = self.first :conditions => ['person_id = ? AND school_year_id = ?', person.id, SchoolYear.current_school_year.id]
    return existing_jersey_number unless existing_jersey_number.nil?
    new_jersey_number = JerseyNumber.new
    new_jersey_number.person = person
    new_jersey_number.school_year = SchoolYear.current_school_year
    new_jersey_number.prefix = prefix
    new_jersey_number.number = next_number
    new_jersey_number.save!
    new_jersey_number
  end
  
  def self.find_jersey_number_for(person, school_year=SchoolYear.current_school_year)
    existing_jersey_number = self.first :conditions => ['person_id = ? AND school_year_id = ?', person.id, school_year.id]
    return '' if existing_jersey_number.nil?
    existing_jersey_number.jersey_number
  end
  
  def self.find_max_number_assigned_for(grade)
    student_ids = grade.current_year_student_class_assignments.collect { |student_class_assignment| student_class_assignment.student.id }
    largest_jersey_number_assigned = self.first :conditions => { :school_year_id => SchoolYear.current_school_year.id, :person_id => student_ids }, :order => 'number DESC'
    return 0 if largest_jersey_number_assigned.nil?
    largest_jersey_number_assigned.number
  end
end
