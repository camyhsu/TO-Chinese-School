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

describe SchoolClass, 'checking active status' do
  fixtures :school_classes, :school_class_active_flags

  before(:each) do
    stub_current_school_year
  end
  
  it 'should return true if school class is active in current school year' do
    school_classes(:first_grade).active_in?(SchoolYear.current_school_year).should be_true
  end

  it 'should return false if school class is not active in current school year' do
    school_classes(:first_grade_class_inactive).active_in?(SchoolYear.current_school_year).should be_false
  end

  it 'should return true if school class is active in given school year' do
    next_school_year = SchoolYear.new
    next_school_year.id = 2
    school_classes(:chinese_history_one).active_in?(next_school_year).should be_true
  end

  it 'should return false if school class is not active in given school year' do
    next_school_year = SchoolYear.new
    next_school_year.id = 2
    school_classes(:chinese_history_two).active_in?(next_school_year).should be_false
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

describe SchoolClass, 'checking if a school age is allowed' do
  before(:each) do
    @school_class = SchoolClass.new
    @random_age = rand(15) + 1
  end

  it 'should return true if both min and max age is nil' do
    @school_class.allow_school_age?(nil).should be_true
  end

  it 'should return true if both min and max age is zero' do
    @school_class.max_age = 0
    @school_class.min_age = 0
    @school_class.allow_school_age?(nil).should be_true
  end

  it 'should return true if given age is less than or equal to max age' do
    @school_class.max_age = @random_age
    @school_class.allow_school_age?(@random_age).should be_true
    @school_class.allow_school_age?(@random_age - 1).should be_true
  end

  it 'should return false if given age is greater than max age' do
    @school_class.max_age = @random_age
    @school_class.allow_school_age?(@random_age + 1).should be_false
  end

  it 'should return true if given age is greater than or equal to min age' do
    @school_class.min_age = @random_age
    @school_class.allow_school_age?(@random_age).should be_true
    @school_class.allow_school_age?(@random_age + 1).should be_true
  end

  it 'should return false if given age is less than min age' do
    @school_class.min_age = @random_age
    @school_class.allow_school_age?(@random_age - 1).should be_false
  end
end

describe SchoolClass, 'finding if the school class is full' do
  fixtures :school_classes, :student_class_assignments

  before(:each) do
    @fake_school_year = SchoolYear.new
    @fake_school_year.id = 1
  end

  it 'should return true if the school class is full' do
    school_classes(:chinese_history_one).elective_is_full_for?(@fake_school_year).should be_true
  end

  it 'should return false if the school class is not full' do
    school_classes(:chinese_history_two).elective_is_full_for?(@fake_school_year).should be_false
  end
end

describe SchoolClass, 'finding all active school classes' do
  fixtures :school_classes, :school_class_active_flags
  
  it 'should find all active school classes for the current year' do
    stub_current_school_year
    active_school_classes = SchoolClass.find_all_active_school_classes
    active_school_classes.should have(4).school_classes
    active_school_classes.should include(school_classes(:first_grade))
    active_school_classes.should include(school_classes(:first_grade_class_b))
    active_school_classes.should include(school_classes(:second_grade))
    active_school_classes.should_not include(school_classes(:first_grade_class_inactive))
    active_school_classes.should_not include(school_classes(:chinese_history_one))
    active_school_classes.should include(school_classes(:chinese_history_two))
  end
end

describe SchoolClass, 'finding all active elective classes' do
  fixtures :school_classes, :school_class_active_flags

  it 'should find all active elective classes for the current year' do
    stub_current_school_year
    active_school_classes = SchoolClass.find_all_active_elective_classes
    active_school_classes.should have(1).school_classes
    active_school_classes.should_not include(school_classes(:chinese_history_one))
    active_school_classes.should include(school_classes(:chinese_history_two))
  end
end
