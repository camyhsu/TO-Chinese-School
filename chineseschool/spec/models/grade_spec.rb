require 'spec_helper'

describe Grade do
  fixtures :grades, :school_classes, :student_class_assignments

  it 'should belongs to the next grade' do
    grades(:first_grade).next_grade.should == grades(:second_grade)
  end

  it 'should has a previous grade' do
    grades(:second_grade).previous_grade.should == grades(:first_grade)
  end

  it 'should have many school classes' do
    grades(:first_grade).should have(4).school_classes
    grades(:first_grade).school_classes.should include(school_classes(:first_grade))
    grades(:first_grade).school_classes.should include(school_classes(:first_grade_class_b))
    grades(:first_grade).school_classes.should include(school_classes(:first_grade_class_c))
    grades(:first_grade).school_classes.should include(school_classes(:first_grade_class_inactive))
  end

  it 'should have many student class assignments' do
    grades(:first_grade).should have(4).student_class_assignments
    grades(:first_grade).student_class_assignments.should include(student_class_assignments(:first_grade_assignment_one))
    grades(:first_grade).student_class_assignments.should include(student_class_assignments(:first_grade_assignment_two))
    grades(:first_grade).student_class_assignments.should_not include(student_class_assignments(:second_grade_assignment_one))
  end

  it 'should have many students through student class assignments' do
    grades(:first_grade).should have(4).students
    grades(:first_grade).students.should include(student_class_assignments(:first_grade_assignment_one).student)
    grades(:first_grade).students.should include(student_class_assignments(:first_grade_assignment_two).student)
    grades(:first_grade).students.should_not include(student_class_assignments(:second_grade_assignment_one).student)
  end
end

describe Grade, 'finding active school classes' do
  fixtures :grades, :school_classes, :school_class_active_flags

  it 'should find active school classes belonging to this grade' do
    stub_current_school_year
    active_school_classes = grades(:first_grade).active_school_classes
    active_school_classes.should have(2).school_classes
    active_school_classes.should include(school_classes(:first_grade))
    active_school_classes.should include(school_classes(:first_grade_class_b))
    active_school_classes.should_not include(school_classes(:first_grade_class_inactive))
  end
end

describe Grade, 'checking if having active school classes in a school year' do
  fixtures :grades, :school_classes, :school_class_active_flags

  before(:each) do
    @fake_school_year = SchoolYear.new
    @fake_school_year.id = 1
  end

  it 'should return true if having active school classes in the given school year' do
    grades(:first_grade).has_active_school_classes_in?(@fake_school_year).should be_true
  end

  it 'should return false if having no active school classes in the given school year' do
    @fake_school_year.id = 2
    grades(:first_grade).has_active_school_classes_in?(@fake_school_year).should be_false
  end

  it 'should return false if having no school classes in the grade' do
    grades(:third_grade).has_active_school_classes_in?(@fake_school_year).should be_false
  end
end

describe Grade, 'snapping down to the first active grade' do
  fixtures :grades, :school_classes, :school_class_active_flags

  before(:each) do
    @fake_school_year = SchoolYear.new
    @fake_school_year.id = 1
  end

  it 'should return the grade itself if it is active' do
    grades(:first_grade).snap_down_to_first_active_grade(@fake_school_year).should == grades(:first_grade)
  end

  it 'should return the highest active grade below itself if it is not active' do
    grades(:third_grade).snap_down_to_first_active_grade(@fake_school_year).should == grades(:second_grade)
  end
end

describe Grade, 'checking if a grade is below first grade' do
  fixtures :grades
  
  it 'should return true for PreK' do
    grades(:pre_grade).below_first_grade?.should be_true
  end

  it 'should return true for K' do
    grades(:k_grade).below_first_grade?.should be_true
  end

  it 'should return false for 1st grade or above' do
    grades(:first_grade).below_first_grade?.should be_false
    grades(:second_grade).below_first_grade?.should be_false
    grades(:third_grade).below_first_grade?.should be_false
  end
end

describe Grade, 'finding grade by school age' do
  fixtures :grades

  # This spec does not cover all cases
  it 'should return nil for school age 3 or below' do
    Grade.find_by_school_age(3).should be_nil
    Grade.find_by_school_age(2).should be_nil
    Grade.find_by_school_age(1).should be_nil
  end
  
  it 'should return grade Pre for school age 4' do
    Grade.find_by_school_age(4).should == grades(:pre_grade)
  end

  it 'should return grade K for school age 5' do
    Grade.find_by_school_age(5).should == grades(:k_grade)
  end

  it 'should return grade 3 for school age 8' do
    Grade.find_by_school_age(8).should == grades(:third_grade)
  end

  it 'should return nil for school age older than highest possible grade' do
    Grade.find_by_school_age(9).should be_nil
    Grade.find_by_school_age(10).should be_nil
    Grade.find_by_school_age(11).should be_nil
  end
end

describe Grade, 'finding next assignable english instruction school class' do
  fixtures :grades, :school_classes

  it 'should find school class of type english instruction' do
    grades(:first_grade).find_next_assignable_school_class(SchoolClass::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION).should == school_classes(:first_grade_class_c)
  end
end

describe Grade, 'finding next assignable traditional school class' do
  fixtures :grades, :school_classes

  it 'should find school class of type traditional' do
    grades(:first_grade).find_next_assignable_school_class(SchoolClass::SCHOOL_CLASS_TYPE_TRADITIONAL).should == school_classes(:first_grade)
  end
end

describe Grade, 'finding next assignable simplified school class' do
  fixtures :grades, :school_classes

  it 'should find school class of type simplified' do
    grades(:first_grade).find_next_assignable_school_class(SchoolClass::SCHOOL_CLASS_TYPE_SIMPLIFIED).should == school_classes(:first_grade_class_b)
  end
end
