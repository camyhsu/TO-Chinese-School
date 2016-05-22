class Accounting::InstructorsController < ApplicationController

  def discount
    @instructor_discounts = []
    SchoolClass.find_all_active_school_classes.each do |school_class|
      instructor_hash = school_class.instructor_assignments
      create_discount_for instructor_hash[InstructorAssignment::ROLE_PRIMARY_INSTRUCTOR], school_class
      create_discount_for instructor_hash[InstructorAssignment::ROLE_SECONDARY_INSTRUCTOR], school_class
    end
    @instructor_discounts.sort! {|a, b| a.school_class_english_name <=> b.school_class_english_name}
  end

  private

  def create_discount_for(instructors, school_class)
    instructors.each { |instructor| @instructor_discounts << InstructorDiscount.create_discount_for(instructor, school_class) }
  end
end
