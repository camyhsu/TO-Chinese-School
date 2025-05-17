# encoding: utf-8
module Student::RegistrationHelper
  
  def display_string_for(school_class_type)
    return 'S(簡)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_SIMPLIFIED
    return 'T(繁)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_TRADITIONAL
    return 'SE(雙語)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION
    return 'EC(實用中文)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_EVERYDAYCHINESE
    return 'ECPS(實用中文 - 親子班)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_EVERYDAYCHINESE_PARENT_AND_STUDENT
    school_class_type
  end

  def label_for_tuition_discount_applied(student_fee_payment)
    discounts = ''
    # return ' (Staff Discount Applied)' if student_fee_payment.staff_discount?
    # return ' (Instructor Discount Applied)' if student_fee_payment.instructor_discount?
    if student_fee_payment.early_registration?
      discounts += ' (Early Registration Discount Applied)'
    end
    if student_fee_payment.staff_discount?
      discounts += ' (Staff Discount Applied)'
    end
    if student_fee_payment.instructor_discount?
      discounts += ' (Instructor Discount Applied)'
    end
    if student_fee_payment.multiple_child_discount?
      discounts += ' (Multiple Child Discount Applied)'
    end
    if student_fee_payment.pre_k_discount?
      discounts += ' (Pre K Discount Applied)'
    end
    discounts
  end
end
