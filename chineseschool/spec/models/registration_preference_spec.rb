require 'spec_helper'

describe RegistrationPreference, 'finding available school class types' do
  fixtures :grades
  
  before(:each) do
    @registration_preference = RegistrationPreference.new
  end
  
  it 'should return a list containing SIMPLIFIED and TRADITIONAL' do
    @registration_preference.grade = grades(:first_grade)
    list = @registration_preference.find_available_school_class_types
    list.should include(RegistrationPreference::SCHOOL_CLASS_TYPE_SIMPLIFIED)
    list.should include(RegistrationPreference::SCHOOL_CLASS_TYPE_TRADITIONAL)
  end

  it 'should return a list containing ENGLISH_INSTRUCTION if the grade is K' do
    @registration_preference.grade = grades(:k_grade)
    @registration_preference.find_available_school_class_types.should include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
  end

  it 'should return a list containing ENGLISH_INSTRUCTION if the grade is 1' do
    @registration_preference.grade = grades(:first_grade)
    @registration_preference.find_available_school_class_types.should include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
  end

  it 'should return a list containing ENGLISH_INSTRUCTION if the grade is 2' do
    @registration_preference.grade = grades(:second_grade)
    @registration_preference.find_available_school_class_types.should include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
  end

  it 'should return a list NOT containing ENGLISH_INSTRUCTION if the grade is not K, 1, or 2' do
    @registration_preference.grade = grades(:third_grade)
    @registration_preference.find_available_school_class_types.should_not include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
  end
end
