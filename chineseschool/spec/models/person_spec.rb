require 'spec_helper'

describe Person, 'showing name' do
  fixtures :people

  it 'should return one blank space in parentheses if no name exists' do
    Person.new.name.should == '( )'
  end

  it 'should return English first name in parentheses if only english first name exists' do
    people(:person_with_only_first_name).name.should == "(#{people(:person_with_only_first_name).english_first_name} )"
  end
  
  it 'should return English last name in parentheses if only english last name exists' do
    people(:person_two).name.should == "( #{people(:person_two).english_last_name})"
  end

  it 'should return English name in parentheses if both english first and last name exist but not chinese name' do
    people(:person_three).name.should == "(#{people(:person_three).english_first_name} #{people(:person_three).english_last_name})"
  end

  it 'should return Chinese name followed by English name in parenthese' do
    people(:person_with_chinese_name).name.should == "#{people(:person_with_chinese_name).chinese_name}(#{people(:person_with_chinese_name).english_first_name} #{people(:person_with_chinese_name).english_last_name})"
  end
end

describe Person, 'finding families' do
  fixtures :people, :families, :families_children

  it 'should find the family while being the parent_one of that family' do
    person_one_families = people(:person_one).families
    person_one_families.should have(1).family
    person_one_families.should include(families(:family_one))
  end

  it 'should find the family while being the parent_two of that family' do
    person_two_families = people(:person_two).families
    person_two_families.should have(1).family
    person_two_families.should include(families(:family_two))
  end

  it 'should find the family while being a child in that family' do
    person_three_families = people(:person_three).families
    person_three_families.should have(1).family
    person_three_families.should include(families(:family_one))
  end
end

describe Person, 'checking if the person is a child' do
  fixtures :people, :families, :families_children

  it 'should return true if the person is a child in any family' do
    a_child = people(:person_three)
    a_child.is_a_child?.should be_true
  end

  it 'should return false if the person is not a child' do
    a_parent = people(:person_one)
    a_parent.is_a_child?.should be_false
  end

  it 'should return true if the person is marked as a new child' do
    a_new_child = Person.new
    a_new_child.mark_as_new_child
    a_new_child.is_a_child?.should be_true
  end

  it 'should return false if the person is new (no id) and is not marked as a new child' do
    a_new_parent = Person.new
    a_new_parent.is_a_child?.should be_false
  end
end

describe Person, 'checking if the person is a parent of the given child' do
  fixtures :people, :families, :families_children

  it 'should return true if the person is a parent of the given child in a family' do
    a_parent = people(:person_one)
    the_child = people(:person_three)
    a_parent.is_a_parent_of?(the_child.id).should be_true
  end

  it 'should return false if the person is not a parent of the given child in any family' do
    not_a_parent = people(:person_two)
    the_child = people(:person_three)
    not_a_parent.is_a_parent_of?(the_child.id).should be_false
  end
end

describe Person, 'validating birth year' do
  fixtures :people, :families, :families_children

  it 'should allow nil birth year if the person is not a child' do
    a_parent = people(:person_one)
    a_parent.birth_year = nil
    a_parent.valid?.should be_true
  end

  it 'should allow blank birth year if the person is not a child' do
    a_parent = people(:person_one)
    a_parent.birth_year = ''
    a_parent.valid?.should be_true
  end

  it 'should not allow nil birth year if the person is a child' do
    a_child = people(:person_three)
    a_child.birth_year = nil
    a_child.valid?.should be_false
  end

  it 'should not allow blank birth year if the person is a child' do
    a_child = people(:person_three)
    a_child.birth_year = ''
    a_child.valid?.should be_false
  end
end

describe Person, 'validating birth month' do
  fixtures :people, :families, :families_children

  it 'should allow nil birth month if the person is not a child' do
    a_parent = people(:person_one)
    a_parent.birth_month = nil
    a_parent.valid?.should be_true
  end

  it 'should allow blank birth month if the person is not a child' do
    a_parent = people(:person_one)
    a_parent.birth_month = ''
    a_parent.valid?.should be_true
  end

  it 'should not allow nil birth month if the person is a child' do
    a_child = people(:person_three)
    a_child.birth_month = nil
    a_child.valid?.should be_false
  end

  it 'should not allow blank birth month if the person is a child' do
    a_child = people(:person_three)
    a_child.birth_month = ''
    a_child.valid?.should be_false
  end
end

describe Person, 'calculating school age for a school year' do
  fixtures :people, :school_years

  it 'should return nil if birth year is nil or blank' do
    parent = people(:person_one)
    parent.birth_year = nil
    parent.school_age_for(nil).should be_nil
    parent.birth_year = ''
    parent.school_age_for(nil).should be_nil
  end

  it 'should return nil if birth month is nil or blank' do
    parent = people(:person_one)
    parent.birth_month = nil
    parent.school_age_for(nil).should be_nil
    parent.birth_month = ''
    parent.school_age_for(nil).should be_nil
  end

  it 'should return the correct school age for birth month before age cutoff' do
    student = people(:person_one)
    student.school_age_for(school_years(:two_thousand_eight)).should == 9
  end

  it 'should return the correct school age for birth month on or after age cutoff' do
    student = people(:person_one)
    student.birth_month = 11
    student.school_age_for(school_years(:two_thousand_eight)).should == 8
  end
end

describe Person, 'creating student class assignment based on registration preference' do
  fixtures :people, :grades, :student_class_assignments, :registration_preferences, :school_classes

  before(:each) do
    stub_current_school_year
  end
  
  it 'should not create student class assignment if registration is already completed' do
    registration_preferences(:preference_six).registration_completed = true
    registration_preferences(:preference_six).save!
    people(:person_six).create_student_class_assignment_based_on_registration_preference SchoolYear.current_school_year
    people(:person_six).student_class_assignments.should == []
  end

  it 'should create a new student class assignment based on registration preference if none exists' do
    # precondition
    people(:person_six).student_class_assignment_for(SchoolYear.current_school_year).should be_nil
    registration_preferences(:preference_six).registration_completed?.should be_false

    people(:person_six).create_student_class_assignment_based_on_registration_preference SchoolYear.current_school_year
    student_class_assignment = people(:person_six).student_class_assignment_for SchoolYear.current_school_year
    student_class_assignment.should_not be_nil
    student_class_assignment.grade.should == grades(:second_grade)
    student_class_assignment.school_class.should == school_classes(:second_grade)
    student_class_assignment.elective_class.should == school_classes(:chinese_history_two)
    people(:person_six).registration_preference_for(SchoolYear.current_school_year).registration_completed?.should be_true
  end

  it 'should update existing student class assignment based on registration preference' do
    # precondition
    existing_student_class_assignment = people(:person_one).student_class_assignment_for SchoolYear.current_school_year
    existing_student_class_assignment.should_not be_nil
    existing_student_class_assignment.grade.should == grades(:first_grade)
    existing_student_class_assignment.school_class.should == school_classes(:first_grade)
    existing_student_class_assignment.elective_class.should == school_classes(:chinese_history_one)
    registration_preferences(:preference_one).registration_completed?.should be_false

    people(:person_one).create_student_class_assignment_based_on_registration_preference SchoolYear.current_school_year
    student_class_assignment = people(:person_one).student_class_assignment_for SchoolYear.current_school_year
    student_class_assignment.should_not be_nil
    student_class_assignment.grade.should == grades(:first_grade)
    student_class_assignment.school_class.should == school_classes(:first_grade_class_c)
    student_class_assignment.elective_class.should == school_classes(:chinese_history_two)
    people(:person_one).registration_preference_for(SchoolYear.current_school_year).registration_completed?.should be_true
  end
end
