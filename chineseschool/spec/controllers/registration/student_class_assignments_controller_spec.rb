require 'spec_helper'

describe Registration::StudentClassAssignmentsController, 'listing active students by name' do
  before(:each) do
    stub_check_authentication_and_authorization_in @controller
    stub_current_school_year
    @active_student_class_assignment_condition = {:conditions => ['school_class_id is not null AND school_year_id = ?', SchoolYear.current_school_year.id]}
    @fake_active_student_class_assignments = create_fake_active_student_class_assignments
  end

  it 'should find all active student class assignments with non-null school class id' do
    StudentClassAssignment.expects(:all).with(@active_student_class_assignment_condition).once.returns(@fake_active_student_class_assignments)
    invoke_get_list_active_students_by_name
  end

  it 'should assign active student class assignments found' do
    StudentClassAssignment.expects(:all).with(@active_student_class_assignment_condition).once.returns(@fake_active_student_class_assignments)
    invoke_get_list_active_students_by_name
    assigns[:active_student_class_assignments].should == @fake_active_student_class_assignments
  end

  it 'should sort active student class assignments found by student english last name then student english first name' do
    StudentClassAssignment.expects(:all).with(@active_student_class_assignment_condition).once.returns(@fake_active_student_class_assignments)
    invoke_get_list_active_students_by_name
    active_student_class_assignments_should_be_sorted
  end

  it 'should be success' do
    invoke_get_list_active_students_by_name
    response.should be_success
  end

  it 'should render list active students by name template' do
    invoke_get_list_active_students_by_name
    response.should render_template('registration/student_class_assignments/list_active_students_by_name.html.erb')
  end

  it 'should respond to correct route' do
    { :get => "/chineseschool/registration/student_class_assignments/list_active_students_by_name" }.should route_to( :controller => 'registration/student_class_assignments', :action => 'list_active_students_by_name' )
  end


  def create_fake_active_student_class_assignments
    fake_assignments = []
    fake_assignments << create_student_class_assignment('Franklin', 'Ben')
    fake_assignments << create_student_class_assignment('Blaes', 'Chris')
    fake_assignments << create_student_class_assignment('Blaes', 'Adam')
    fake_assignments
  end

  def active_student_class_assignments_should_be_sorted
    @fake_active_student_class_assignments[0].student.english_last_name.should == 'Blaes'
    @fake_active_student_class_assignments[0].student.english_first_name.should == 'Adam'
    @fake_active_student_class_assignments[1].student.english_last_name.should == 'Blaes'
    @fake_active_student_class_assignments[1].student.english_first_name.should == 'Chris'
    @fake_active_student_class_assignments[2].student.english_last_name.should == 'Franklin'
    @fake_active_student_class_assignments[2].student.english_first_name.should == 'Ben'
  end

  def create_student_class_assignment(english_last_name, english_first_name)
    student_class_assignment = StudentClassAssignment.new
    student_class_assignment.school_year = SchoolYear.current_school_year
    student = Person.new
    student.english_first_name = english_first_name
    student.english_last_name = english_last_name
    student_class_assignment.student = student
    student_class_assignment
  end

  def invoke_get_list_active_students_by_name
     get :list_active_students_by_name
  end
end
