require 'spec_helper'

describe InstructorAssignment do
  fixtures :instructor_assignments, :people, :school_classes, :school_years

  before(:each) do
    @instructor_assignment = instructor_assignments(:minimal)
  end

  it 'should define role constants' do
    InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR.should == 'Primary Instructor'
    InstructorAssignment::ROLE_ROOM_PARENT.should == 'Room Parent'
    InstructorAssignment::ROLE_SECONDARY_INSTRUCTOR.should == 'Secondary Instructor'
    InstructorAssignment::ROLE_TEACHING_ASSISTANT.should == 'Teaching Assistant'

    InstructorAssignment::ROLES.should include(InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR)
    InstructorAssignment::ROLES.should include(InstructorAssignment::ROLE_ROOM_PARENT)
    InstructorAssignment::ROLES.should include(InstructorAssignment::ROLE_SECONDARY_INSTRUCTOR)
    InstructorAssignment::ROLES.should include(InstructorAssignment::ROLE_TEACHING_ASSISTANT)
  end

  it 'should belongs to shool year' do
    @instructor_assignment.school_year.should == school_years(:two_thousand_eight)
  end

  it 'should belongs to shool class' do
    @instructor_assignment.school_class.should == school_classes(:first_grade)
  end

  it 'should belongs to instructor' do
    @instructor_assignment.instructor.should == people(:person_one)
  end
  
  it 'should be invalid without school year' do
    @instructor_assignment.school_year = nil
    @instructor_assignment.should_not be_valid
    @instructor_assignment.school_year = school_years(:two_thousand_eight)
    @instructor_assignment.should be_valid
  end

  it 'should be invalid without school class' do
    @instructor_assignment.school_class = nil
    @instructor_assignment.should_not be_valid
    @instructor_assignment.school_class = school_classes(:first_grade)
    @instructor_assignment.should be_valid
  end

  it 'should be invalid without instructor' do
    @instructor_assignment.instructor = nil
    @instructor_assignment.should_not be_valid
    @instructor_assignment.instructor = people(:person_one)
    @instructor_assignment.should be_valid
  end

  it 'should be invalid without start date' do
    @instructor_assignment.start_date = nil
    @instructor_assignment.should_not be_valid
    @instructor_assignment.start_date = Date.parse('2008-09-06')
    @instructor_assignment.should be_valid
  end

  it 'should be invalid without end date' do
    @instructor_assignment.end_date = nil
    @instructor_assignment.should_not be_valid
    @instructor_assignment.end_date = Date.parse('2009-06-06')
    @instructor_assignment.should be_valid
  end

  it 'should be invalid without role' do
    @instructor_assignment.role = nil
    @instructor_assignment.should_not be_valid
    @instructor_assignment.role = random_string 8
    @instructor_assignment.should be_valid
  end

  it 'should be invalid if start date is later than end date' do
    @instructor_assignment.start_date = Date.parse('2008-09-07')
    @instructor_assignment.end_date = Date.parse('2008-09-06')
    @instructor_assignment.should_not be_valid
    @instructor_assignment.start_date = Date.parse('2008-09-06')
    @instructor_assignment.should be_valid
  end

  it 'should be invalid if dates overlapping with another instructor assignment - starts before the other ends' do
    @instructor_assignment.start_date = Date.parse('2008-09-07')
    @instructor_assignment.end_date = Date.parse('2008-10-06')
    setup_expectations_for_finding_existing_instructor_assignments
    @instructor_assignment.should_not be_valid
  end

  it 'should be invalid if dates overlapping with another instructor assignment - ends after the other starts' do
    @instructor_assignment.start_date = Date.parse('2008-06-07')
    @instructor_assignment.end_date = Date.parse('2008-07-16')
    setup_expectations_for_finding_existing_instructor_assignments
    @instructor_assignment.should_not be_valid
  end

  it 'should be invalid if dates overlapping with another instructor assignment - enclosing dates for the other' do
    @instructor_assignment.start_date = Date.parse('2008-07-07')
    @instructor_assignment.end_date = Date.parse('2008-09-16')
    setup_expectations_for_finding_existing_instructor_assignments
    @instructor_assignment.should_not be_valid
  end

  it 'should be invalid if dates overlapping with another instructor assignment - enclosed by dates for the other' do
    @instructor_assignment.start_date = Date.parse('2008-08-17')
    @instructor_assignment.end_date = Date.parse('2008-08-18')
    setup_expectations_for_finding_existing_instructor_assignments
    @instructor_assignment.should_not be_valid
  end

  def setup_expectations_for_finding_existing_instructor_assignments
    existing_instructor_assignment_one = InstructorAssignment.new
    existing_instructor_assignment_one.start_date = Date.parse('2008-07-10')
    existing_instructor_assignment_one.end_date = Date.parse('2008-08-09')
    existing_instructor_assignment_one.instructor = people(:person_one)
    existing_instructor_assignment_two = InstructorAssignment.new
    existing_instructor_assignment_two.start_date = Date.parse('2008-08-10')
    existing_instructor_assignment_two.end_date = Date.parse('2008-09-10')
    existing_instructor_assignment_two.instructor = people(:person_two)
    InstructorAssignment.expects(:find_all_by_school_year_id_and_school_class_id_and_role).with(
        @instructor_assignment.school_year.id, @instructor_assignment.school_class.id, @instructor_assignment.role).once.returns(
        [existing_instructor_assignment_one, existing_instructor_assignment_two])
  end
end

describe InstructorAssignment, 'displaying date as string' do
  fixtures :instructor_assignments
  
  before(:each) do
    @instructor_assignment = InstructorAssignment.new
  end
  
  it 'should display start date string as yyyy-MM-dd' do
    @instructor_assignment.start_date = Date.parse('2008-07-10')
    @instructor_assignment.start_date_string.should == '2008-07-10'
  end

  it 'should return start date string as empty string if start date is nil' do
    @instructor_assignment.start_date.should be_nil
    @instructor_assignment.start_date_string.should == ''
  end

  it 'should display end date string as yyyy-MM-dd' do
    @instructor_assignment.end_date = Date.parse('2008-07-10')
    @instructor_assignment.end_date_string.should == '2008-07-10'
  end

  it 'should return end date string as empty string if end date is nil' do
    @instructor_assignment.end_date.should be_nil
    @instructor_assignment.end_date_string.should == ''
  end
end
