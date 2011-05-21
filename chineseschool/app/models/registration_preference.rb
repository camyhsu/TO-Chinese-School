class RegistrationPreference < ActiveRecord::Base
  
  SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION = 'SE'
  SCHOOL_CLASS_TYPE_SIMPLIFIED = 'S'
  SCHOOL_CLASS_TYPE_TRADITIONAL = 'T'

  belongs_to :school_year
  belongs_to :person
  belongs_to :entered_by, :class_name => 'Person', :foreign_key => 'entered_by_id'

  validates_presence_of :school_year, :person, :entered_by

  def self.find_available_school_class_types(grade)
    return nil if grade.nil?
    available_school_class_types = []
    available_school_class_types << SCHOOL_CLASS_TYPE_SIMPLIFIED
    available_school_class_types << SCHOOL_CLASS_TYPE_TRADITIONAL
    if ('K' == grade.short_name) or ('1' == grade.short_name) or ('2' == grade.short_name)
      available_school_class_types << SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION
    end
    available_school_class_types
  end
end
