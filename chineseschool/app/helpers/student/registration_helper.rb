# encoding: utf-8
module Student::RegistrationHelper
  
  def display_string_for(school_class_type)
    return 'S(簡)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_SIMPLIFIED
    return 'T(繁)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_TRADITIONAL
    return 'SE(雙語)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_ENGLISH_INSTRUCTION
    return 'EC(實用中文)' if school_class_type == SchoolClass::SCHOOL_CLASS_TYPE_EVERYDAYCHINESE
    school_class_type
  end

  def label_for_tuition_discount_applied(student_fee_payment)
    return ' (Staff Discount Applied)' if student_fee_payment.staff_discount?
    return ' (Instructor Discount Applied)' if student_fee_payment.instructor_discount?
    ''
  end
end
