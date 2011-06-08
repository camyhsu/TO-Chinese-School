require 'spec_helper'

describe StudentClassAssignment, 'setting school class based on registration preference' do
  fixtures :grades, :school_classes

  it 'should set school class to english instruction class if registration preference demands english instruction' do
    registration_preference = RegistrationPreference.new
    registration_preference.school_class_type = RegistrationPreference::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION
    student_class_assignment = StudentClassAssignment.new
    student_class_assignment.grade = grades(:first_grade)
    student_class_assignment.set_school_class_based_on registration_preference
    student_class_assignment.school_class.should == school_classes(:first_grade_class_c)
  end

  it 'should set school class to traditional class if registration preference demands traditional' do
    registration_preference = RegistrationPreference.new
    registration_preference.school_class_type = RegistrationPreference::SCHOOL_CLASS_TYPE_TRADITIONAL
    student_class_assignment = StudentClassAssignment.new
    student_class_assignment.grade = grades(:first_grade)
    student_class_assignment.set_school_class_based_on registration_preference
    student_class_assignment.school_class.should == school_classes(:first_grade)
  end

  it 'should not set school class if registration preference demands simplified' do
    registration_preference = RegistrationPreference.new
    registration_preference.school_class_type = RegistrationPreference::SCHOOL_CLASS_TYPE_SIMPLIFIED
    student_class_assignment = StudentClassAssignment.new
    student_class_assignment.grade = grades(:first_grade)
    student_class_assignment.set_school_class_based_on registration_preference
    student_class_assignment.school_class.should be_nil
  end
end
