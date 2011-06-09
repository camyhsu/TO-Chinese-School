require 'spec_helper'

describe StudentFeePayment, 'calculating total' do
  before(:each) do
    @student_fee_payment = StudentFeePayment.new

    @registration_fee_in_cents = rand 100000
    @student_fee_payment.registration_fee_in_cents = @registration_fee_in_cents
    @book_charge_in_cents = rand 100000
    @student_fee_payment.book_charge_in_cents = @book_charge_in_cents
    @tuition_in_cents = rand 100000
    @student_fee_payment.tuition_in_cents = @tuition_in_cents
  end

  it 'should return the total of all tuition and fee' do
    @student_fee_payment.total_in_cents.should == (@registration_fee_in_cents + @book_charge_in_cents + @tuition_in_cents)
  end
end

describe StudentFeePayment, 'filling in tuition and fee' do
  before(:each) do
    @student_fee_payment = StudentFeePayment.new

    @fake_school_year = SchoolYear.new
    @registration_fee_in_cents = rand 100000
    @fake_school_year.registration_fee_in_cents = @registration_fee_in_cents
    @book_charge_in_cents = rand 100000
    @fake_school_year.book_charge_in_cents = @book_charge_in_cents

    @fake_grade = Grade.new
    @fake_registration_count_before_this_student = rand 100
  end
  
  it 'should fill in registration fee and book charge and calculate tuition' do
    @student_fee_payment.registration_fee_in_cents.should be_nil
    @student_fee_payment.book_charge_in_cents.should be_nil
    @student_fee_payment.expects(:calculate_tuition).once.with(@fake_school_year, @fake_grade, @fake_registration_count_before_this_student)
    @student_fee_payment.fill_in_tuition_and_fee(@fake_school_year, @fake_grade, @fake_registration_count_before_this_student)
    @student_fee_payment.registration_fee_in_cents.should == @registration_fee_in_cents
    @student_fee_payment.book_charge_in_cents.should == @book_charge_in_cents
  end
end

describe StudentFeePayment, 'calculating tuition' do
  before(:each) do
    @student_fee_payment = StudentFeePayment.new

    @fake_school_year = SchoolYear.new
    @fake_school_year.pre_registration_end_date = Date.today
    @tuition_in_cents = rand 100000
    @fake_school_year.tuition_in_cents = @tuition_in_cents
    @pre_registration_tuition_in_cents = rand 100000
    @fake_school_year.pre_registration_tuition_in_cents = @pre_registration_tuition_in_cents

    @fake_grade = Grade.new
    @fake_existing_student_count_in_family = rand 100
  end

  it 'should apply PreK and multiple child discount' do
    @student_fee_payment.expects(:apply_pre_k_discount).once.with(@fake_school_year, @fake_grade)
    @student_fee_payment.expects(:apply_multiple_child_discount).once.with(@fake_school_year, @fake_existing_student_count_in_family)
    @student_fee_payment.calculate_tuition(@fake_school_year, @fake_grade, @fake_existing_student_count_in_family)
  end

  it 'should use pre-registration tuition if today is on or before pre_registration_end_date' do
    @student_fee_payment.expects(:apply_pre_k_discount).once.with(@fake_school_year, @fake_grade)
    @student_fee_payment.expects(:apply_multiple_child_discount).once.with(@fake_school_year, @fake_existing_student_count_in_family)
    @student_fee_payment.calculate_tuition(@fake_school_year, @fake_grade, @fake_existing_student_count_in_family)
    @student_fee_payment.tuition_in_cents.should == @pre_registration_tuition_in_cents
  end

  it 'should use pre-registration tuition if today is after pre_registration_end_date' do
    @fake_school_year.pre_registration_end_date = Date.yesterday
    @student_fee_payment.expects(:apply_pre_k_discount).once.with(@fake_school_year, @fake_grade)
    @student_fee_payment.expects(:apply_multiple_child_discount).once.with(@fake_school_year, @fake_existing_student_count_in_family)
    @student_fee_payment.calculate_tuition(@fake_school_year, @fake_grade, @fake_existing_student_count_in_family)
    @student_fee_payment.tuition_in_cents.should == @tuition_in_cents
  end
end

describe StudentFeePayment, 'applying PreK discount' do
  before(:each) do
    @student_fee_payment = StudentFeePayment.new
    @original_tuition_in_cents = rand 100000
    @student_fee_payment.tuition_in_cents = @original_tuition_in_cents
    @book_charge_in_cents = rand 1000
    @student_fee_payment.book_charge_in_cents = @book_charge_in_cents

    @fake_school_year = SchoolYear.new
    @discount_in_cents = rand 1000
    @fake_school_year.tuition_discount_for_pre_k_in_cents = @discount_in_cents
  end

  it 'should apply PreK discount if given grade is PreK' do
    @student_fee_payment.apply_pre_k_discount(@fake_school_year, Grade::GRADE_PRESCHOOL)
    @student_fee_payment.pre_k_discount.should be_true
    @student_fee_payment.tuition_in_cents.should == (@original_tuition_in_cents - @discount_in_cents)
    @student_fee_payment.book_charge_in_cents.should == 0
  end

  it 'should not apply PreK discount if given grade is not PreK' do
    @student_fee_payment.apply_pre_k_discount(@fake_school_year, Grade.new)
    @student_fee_payment.pre_k_discount.should be_false
    @student_fee_payment.tuition_in_cents.should == @original_tuition_in_cents
    @student_fee_payment.book_charge_in_cents.should == @book_charge_in_cents
  end
end

describe StudentFeePayment, 'applying multiple child discount' do
  before(:each) do
    @student_fee_payment = StudentFeePayment.new
    @original_tuition_in_cents = rand 100000
    @student_fee_payment.tuition_in_cents = @original_tuition_in_cents

    @fake_school_year = SchoolYear.new
    @discount_in_cents = rand 1000
    @fake_school_year.tuition_discount_for_three_or_more_child_in_cents = @discount_in_cents
  end

  it 'should apply multiple child discount if registration count before this student is 2 or more' do
    @student_fee_payment.apply_multiple_child_discount(@fake_school_year, 2)
    @student_fee_payment.multiple_child_discount.should be_true
    @student_fee_payment.tuition_in_cents.should == (@original_tuition_in_cents - @discount_in_cents)
  end

  it 'should not apply multiple child discount if registration count before this student is 1 or less' do
    @student_fee_payment.apply_multiple_child_discount(@fake_school_year, 1)
    @student_fee_payment.multiple_child_discount.should be_false
    @student_fee_payment.tuition_in_cents.should == @original_tuition_in_cents
  end
end
