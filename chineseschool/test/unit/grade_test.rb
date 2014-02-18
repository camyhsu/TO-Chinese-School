require 'test_helper'

class GradeTest < ActiveSupport::TestCase
  fixtures :grades
  # test "the truth" do
  #   assert true
  # end
  test 'school age of a grade' do
    #grade_preschool = Grade.find_by_short_name 'Pre'
    assert_equal 4, grades(:pre_grade).school_age
    assert_equal 5, grades(:k_grade).school_age
    assert_equal 6, grades(:first_grade).school_age
    assert_equal 7, grades(:second_grade).school_age
  end
end
