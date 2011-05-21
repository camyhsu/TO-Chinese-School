require 'spec_helper'

describe RegistrationPreference, 'finding available school class types' do
  fixtures :grades

  it 'should return nil if give grade is nil' do
    RegistrationPreference.find_available_school_class_types(nil).should be_nil
  end

  it 'should return a list containing SIMPLIFIED and TRADITIONAL' do
    list = RegistrationPreference.find_available_school_class_types(grades(:first_grade))
    list.should include(RegistrationPreference::SCHOOL_CLASS_TYPE_SIMPLIFIED)
    list.should include(RegistrationPreference::SCHOOL_CLASS_TYPE_TRADITIONAL)
  end

  it 'should return a list containing ENGLISH_INSTRUCTION if the grade is K, 1, or 2' do
    RegistrationPreference.find_available_school_class_types(grades(:k_grade)).should include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
    RegistrationPreference.find_available_school_class_types(grades(:first_grade)).should include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
    RegistrationPreference.find_available_school_class_types(grades(:second_grade)).should include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
  end

  it 'should return a list NOT containing ENGLISH_INSTRUCTION if the grade is not K, 1, or 2' do
    RegistrationPreference.find_available_school_class_types(grades(:third_grade)).should_not include(RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION)
  end
end
