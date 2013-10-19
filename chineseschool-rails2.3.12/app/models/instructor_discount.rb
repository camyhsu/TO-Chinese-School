class InstructorDiscount

  DISCOUNT_AMOUNT_PER_CHILD = 60

  attr_reader :school_class_name, :instructor_name, :child_one_name, :child_two_name, :discount_amount

  def initialize(school_class_name, instructor_name)
    @school_class_name = school_class_name
    @instructor_name = instructor_name
  end

  def fill_in_discount_amount_for(instructor)
    instructor.find_children.each do |child|
      record_name_from(child) if child.student_status_flag_for(SchoolYear.current_school_year).try(:registered?)
    end
    calculate_discount
  end

  def record_name_from(child)
    if @child_one_name.nil?
      @child_one_name = child.name
    else
      @child_two_name = child.name if @child_two_name.nil?
    end
  end

  def calculate_discount
    if @child_two_name.nil?
      if @child_one_name.nil?
        @discount_amount = 0
      else
        @discount_amount = DISCOUNT_AMOUNT_PER_CHILD
      end
    else
      @discount_amount = DISCOUNT_AMOUNT_PER_CHILD * 2
    end
  end

  def self.create_discount_for(instructor, school_class)
    discount = InstructorDiscount.new school_class.name, instructor.name
    discount.fill_in_discount_amount_for instructor
    discount
  end
end
