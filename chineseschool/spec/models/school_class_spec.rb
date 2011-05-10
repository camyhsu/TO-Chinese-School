require 'spec_helper'

describe SchoolClass do

  it 'should have an instructor assignment history' do
    SchoolClass.new.instructor_assignment_history.should_not be_nil
  end
end

describe SchoolClass, 'showing name' do
  it 'should combine chinese name and english name when showing name' do
    school_class = SchoolClass.new
    school_class.chinese_name = random_string
    school_class.english_name = random_string 12
    school_class.name.should == "#{school_class.chinese_name}(#{school_class.english_name})"
  end
end

describe SchoolClass, 'checking elective status' do
  fixtures :school_classes
  
  it 'should return true for elective? if no grade is associated with it' do
    school_classes(:chinese_history_one).elective?.should be_true
  end

  it 'should return false for elective? if there is an associated grade' do
    school_classes(:first_grade).elective?.should_not be_true
  end
end

describe SchoolClass, 'counting class size' do
  fixtures :school_classes, :student_class_assignments

  before(:each) do
    stub_current_school_year
  end

  it 'should count class size correctly for school class' do
    school_classes(:first_grade).class_size.should == 4
    school_classes(:first_grade_class_b).class_size.should == 0
  end

  it 'should count class size correctly for elective class' do
    school_classes(:chinese_history_one).class_size.should == 3
  end
end

describe SchoolClass, 'finding students' do
  fixtures :school_classes, :student_class_assignments, :people

  before(:each) do
    stub_current_school_year
  end

  it 'should find students for school class' do
    students = school_classes(:first_grade).students
    students.size.should == 4
    # Asserting sort order - english_last_name ASC, english_first_name ASC
    students[0].should == people(:person_four)
    students[1].should == people(:person_three)
    students[2].should == people(:person_two)
    students[3].should == people(:person_one)
  end

  it 'should find students for elective class' do
    students = school_classes(:chinese_history_one).students
    students.size.should == 3
    # Asserting sort order - english_last_name ASC, english_first_name ASC
    students[0].should == people(:person_with_chinese_name)
    students[1].should == people(:person_four)
    students[2].should == people(:person_one)
  end
end

describe SchoolClass, 'finding current instructor assignments' do

  it 'should find instructor assignments for the current school year'
end
