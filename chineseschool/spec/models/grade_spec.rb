require 'spec_helper'

describe Grade do
  fixtures :grades, :school_classes, :student_class_assignments, :people

  it 'should belong to the next grade' do
    expect(grades(:first_grade).next_grade).to eq(grades(:second_grade))
  end

  it 'should have a previous grade' do
    expect(grades(:second_grade).previous_grade).to eq(grades(:first_grade))
  end

  it 'should have many school classes' do
    expect(grades(:first_grade)).to have(4).school_classes
    expect(grades(:first_grade).school_classes).to include(school_classes(:first_grade_class_a))
    expect(grades(:first_grade).school_classes).to include(school_classes(:first_grade_class_b))
    expect(grades(:first_grade).school_classes).to include(school_classes(:first_grade_class_c))
    expect(grades(:first_grade).school_classes).to include(school_classes(:first_grade_class_inactive))
  end

  it 'should have many student class assignments' do
    expect(grades(:first_grade)).to have(4).student_class_assignments
    expect(grades(:first_grade).student_class_assignments).to include(student_class_assignments(:first_grade_assignment_one))
    expect(grades(:first_grade).student_class_assignments).to include(student_class_assignments(:first_grade_assignment_two))
    expect(grades(:first_grade).student_class_assignments).to include(student_class_assignments(:first_grade_assignment_three))
    expect(grades(:first_grade).student_class_assignments).to include(student_class_assignments(:first_grade_assignment_four))
    expect(grades(:first_grade).student_class_assignments).not_to include(student_class_assignments(:second_grade_assignment_one))
  end

  it 'should have many students through student class assignments' do
    expect(grades(:first_grade)).to have(4).students
    expect(grades(:first_grade).students).to include(student_class_assignments(:first_grade_assignment_one).student)
    expect(grades(:first_grade).students).to include(student_class_assignments(:first_grade_assignment_two).student)
    expect(grades(:first_grade).students).to include(student_class_assignments(:first_grade_assignment_three).student)
    expect(grades(:first_grade).students).to include(student_class_assignments(:first_grade_assignment_four).student)
    expect(grades(:first_grade).students).not_to include(student_class_assignments(:second_grade_assignment_one).student)
  end
end

describe Grade, '#active_grade_classes' do
  fixtures :grades, :school_classes, :school_class_active_flags

  it 'should find active grade classes belonging to this grade' do
    stub_current_school_year
    active_grade_classes = grades(:first_grade).active_grade_classes
    expect(active_grade_classes).to have(3).school_classes
    expect(active_grade_classes).to include(school_classes(:first_grade_class_a))
    expect(active_grade_classes).to include(school_classes(:first_grade_class_b))
    expect(active_grade_classes).to include(school_classes(:first_grade_class_c))
    expect(active_grade_classes).not_to include(school_classes(:first_grade_class_inactive))
  end
end

describe Grade, '#has_active_grade_classes_in?' do
  fixtures :grades, :school_classes, :school_class_active_flags

  before(:each) do
    @fake_school_year = SchoolYear.new
    @fake_school_year.id = 1
  end

  it 'should return true if having active school classes in the given school year' do
    expect(grades(:first_grade).has_active_grade_classes_in? @fake_school_year).to be true
  end

  it 'should return false if having no active school classes in the given school year' do
    @fake_school_year.id = 2
    expect(grades(:first_grade).has_active_grade_classes_in? @fake_school_year).to be false
  end

  it 'should return false if having no school classes in the grade' do
    expect(grades(:third_grade).has_active_grade_classes_in? @fake_school_year).to be false
  end
end

describe Grade, '#snap_down_to_first_active_grade' do
  fixtures :grades, :school_classes, :school_class_active_flags

  before(:each) do
    @fake_school_year = SchoolYear.new
    @fake_school_year.id = 1
  end

  it 'should return the grade itself if it is active' do
    expect(grades(:first_grade).snap_down_to_first_active_grade @fake_school_year).to eq(grades(:first_grade))
  end

  it 'should return the highest active grade below itself if it is not active' do
    expect(grades(:third_grade).snap_down_to_first_active_grade @fake_school_year).to eq(grades(:second_grade))
  end
end

describe Grade, '#below_first_grade?' do
  fixtures :grades
  
  it 'should return true for PreK' do
    expect(grades(:pre_grade).below_first_grade?).to be true
  end

  it 'should return true for K' do
    expect(grades(:k_grade).below_first_grade?).to be true
  end

  it 'should return false for 1st grade or above' do
    expect(grades(:first_grade).below_first_grade?).to be false
    expect(grades(:second_grade).below_first_grade?).to be false
    expect(grades(:third_grade).below_first_grade?).to be false
  end
end

describe Grade, '.find_by_school_age' do
  fixtures :grades

  # This spec does not cover all cases
  it 'should return nil for school age 3 or below' do
    expect(Grade.find_by_school_age 3).to be_nil
    expect(Grade.find_by_school_age 2).to be_nil
    expect(Grade.find_by_school_age 1).to be_nil
  end
  
  it 'should return grade Pre for school age 4' do
    expect(Grade.find_by_school_age 4).to eq(grades(:pre_grade))
  end

  it 'should return grade K for school age 5' do
    expect(Grade.find_by_school_age 5).to eq(grades(:k_grade))
  end

  it 'should return grade 3 for school age 8' do
    expect(Grade.find_by_school_age 8).to eq(grades(:third_grade))
  end

  it 'should return nil for school age older than highest possible grade' do
    expect(Grade.find_by_school_age 9).to be_nil
    expect(Grade.find_by_school_age 10).to be_nil
    expect(Grade.find_by_school_age 11).to be_nil
  end
end

describe Grade, '#find_next_assignable_school_class' do
  fixtures :grades, :school_classes, :school_class_active_flags, :school_years

  it 'should return nil if no school class found'

  it 'should find school class of type english instruction when specified so' do
    expect(grades(:first_grade).find_next_assignable_school_class(SchoolClass::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION, school_years(:two_thousand_eight), nil)).to eq(school_classes(:first_grade_class_c))
  end

  it 'should find school class of type traditional when specified so' do
    expect(grades(:first_grade).find_next_assignable_school_class(SchoolClass::SCHOOL_CLASS_TYPE_TRADITIONAL, school_years(:two_thousand_eight), nil)).to eq(school_classes(:first_grade_class_a))
  end

  it 'should find school class of type simplified when specified so' do
    expect(grades(:first_grade).find_next_assignable_school_class(SchoolClass::SCHOOL_CLASS_TYPE_SIMPLIFIED, school_years(:two_thousand_eight), nil)).to eq(school_classes(:first_grade_class_b))
  end
end

describe Grade, '#school_age' do
  fixtures :grades

  it 'should return the school age of the grade' do
    expect(grades(:pre_grade).school_age).to eq(4)
    expect(grades(:k_grade).school_age).to eq(5)
    expect(grades(:first_grade).school_age).to eq(6)
    expect(grades(:second_grade).school_age).to eq(7)
  end
end

