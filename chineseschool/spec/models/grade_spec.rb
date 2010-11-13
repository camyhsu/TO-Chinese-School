require 'spec_helper'

describe Grade do
  fixtures :grades, :school_classes, :student_class_assignments

  it 'should belongs to the next grade' do
    grades(:first_grade).next_grade.should == grades(:second_grade)
  end

  it 'should have many active school classes' do
    grades(:first_grade).should have(2).school_classes
    grades(:first_grade).school_classes.should include(school_classes(:first_grade))
    grades(:first_grade).school_classes.should include(school_classes(:first_grade_class_b))
    grades(:first_grade).school_classes.should_not include(school_classes(:first_grade_class_inactive))
  end

  it 'should have many student class assignments' do
    grades(:first_grade).should have(2).student_class_assignments
    grades(:first_grade).student_class_assignments.should include(student_class_assignments(:first_grade_assignment_one))
    grades(:first_grade).student_class_assignments.should include(student_class_assignments(:first_grade_assignment_two))
    grades(:first_grade).student_class_assignments.should_not include(student_class_assignments(:second_grade_assignment_one))
  end

  it 'should have many students through student class assignments' do
    grades(:first_grade).should have(2).students
    grades(:first_grade).students.should include(student_class_assignments(:first_grade_assignment_one).student)
    grades(:first_grade).students.should include(student_class_assignments(:first_grade_assignment_two).student)
    grades(:first_grade).students.should_not include(student_class_assignments(:second_grade_assignment_one).student)
  end
end
